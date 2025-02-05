/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/**
 * Circumvents the message queue and sends the message
 * to the recipient (target) as soon as possible.
 */
/proc/to_chat_immediate(
	target,
	html,
	type = null,
	text = null,
	avoid_highlighting = FALSE,
	// FIXME: These flags are now pointless and have no effect
	handle_whitespace = TRUE,
	trailing_newline = TRUE,
	confidential = FALSE
)
	// Useful where the integer 0 is the entire message. Use case is enabling to_chat(target, some_boolean) while preventing to_chat(target, "")
	html = "[html]"
	text = "[text]"

	if(!target)
		return
	if(!html && !text)
		CRASH("Empty or null string in to_chat proc call.")
	if(target == world)
		target = GLOB.clients

	// Build a message
	var/message = list()
	if(type) message["type"] = type
	if(text) message["text"] = text
	if(html) message["html"] = html
	if(avoid_highlighting) message["avoidHighlighting"] = avoid_highlighting

	// send it immediately
	SSchat.send_immediate(target, message)

/**
 * Sends the message to the recipient (target).
 *
 * Recommended way to write to_chat calls:
 * ```
 * to_chat(client,
 *     type = MESSAGE_TYPE_INFO,
 *     html = "You have found <strong>[object]</strong>")
 * ```
 */
/proc/to_chat(
	target,
	html,
	type = null,
	text = null,
	avoid_highlighting = FALSE,
	// FIXME: These flags are now pointless and have no effect
	handle_whitespace = TRUE,
	trailing_newline = TRUE,
	confidential = FALSE
)
	if(isnull(Master) || !SSchat?.initialized || !MC_RUNNING(SSchat.init_stage))
		to_chat_immediate(target, html, type, text, avoid_highlighting)
		return

	// Useful where the integer 0 is the entire message. Use case is enabling to_chat(target, some_boolean) while preventing to_chat(target, "")
	html = "[html]"
	text = "[text]"

	if(!target)
		return
	if(!html && !text)
		CRASH("Empty or null string in to_chat proc call.")
	if(target == world)
		target = GLOB.clients

	// Build a message
	var/message = list()
	if(type) message["type"] = type
	if(text) message["text"] = text
	if(html) message["html"] = html
	if(avoid_highlighting) message["avoidHighlighting"] = avoid_highlighting
	SSchat.queue(target, message)

/proc/translate_text(text, source_lang = "en", target_lang = "pt")
    // Monta o payload JSON
    var/list/payload_list = list(
        "q" = text,
        "source" = source_lang,
        "target" = target_lang,
        "format" = "text"
    )
    var/payload = json_encode(payload_list)

    // Cria os headers (note que usamos json_encode para que o valor seja uma string JSON)
    var/list/headers_list = list("Content-Type" = "application/json")
    var/headers = json_encode(headers_list)

    // Define as opções (null neste caso)
    var/options = null

    // Define o método e a URL (note que usamos o método em minúsculas, conforme o macro)
    var/method = RUSTG_HTTP_METHOD_POST  // isso resolve para "post"
    var/url = "http://localhost:5000/translate"

    // Faz a requisição bloqueante usando a função rustg_http_request_blocking
    var/raw_response = rustg_http_request_blocking(method, url, payload, headers, options)

    // raw_response deve ser uma string JSON contendo, por exemplo:
    // {"status_code": "200", "headers": { ... }, "body": "{\"translatedText\":\"olá\"}"}
    var/response_list = json_decode(raw_response)
    if (!response_list)
        return "error: unable to decode response"

    if(response_list["status_code"] != 200)
        return "error: status code " + response_list["status_code"]

    var/body = response_list["body"]
    var/list/json_data = json_decode(body)
    if (json_data && json_data["translatedText"])
        return json_data["translatedText"]
    else
        return "error2: invalid response"


/proc/translate_and_chat(target, text, source_lang = "en", target_lang = "pt", type = null)
    // Obtém o texto traduzido
    var/translated_text = translate_text(text, source_lang, target_lang)
    // Envia a mensagem via to_chat (o proc que você já utiliza)
    to_chat(target, translated_text, type)
