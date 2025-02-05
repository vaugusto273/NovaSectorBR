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
    // Cria um objeto de requisição HTTP
    var/datum/http_request/req = new /datum/http_request

    // Constrói o payload JSON com os parâmetros necessários.
    // Certifique-se de que o texto não contenha aspas que possam quebrar o JSON.
    var/payload = json_encode(list(
    "q" = text,
    "source" = source_lang,
    "target" = target_lang,
    "format" = "text"
))
    // Prepara a requisição com o método POST, endpoint adequado e cabeçalhos
    req.prepare("POST", "http://localhost:5000/translate", payload, list("Content-Type" = "application/json"), null)
    // Executa a requisição de forma bloqueante para aguardar a resposta
    req.execute_blocking()

    // Converte a resposta bruta em um objeto http_response
    var/datum/http_response/resp = req.into_response()
    if(resp.errored)
        return "error"

    // Decodifica o corpo da resposta, que é uma string JSON
    var/list/json_data = json_decode(resp.body)
    if(json_data && json_data["translatedText"])
        return json_data["translatedText"]
    else
        return "error2"

/proc/translate_and_chat(target, text, source_lang = "en", target_lang = "pt", type = text)
    // Obtém o texto traduzido
    var/translated_text = translate_text(text, source_lang, target_lang)
    // Envia a mensagem via to_chat (o proc que você já utiliza)
    to_chat(target, translated_text, type)
