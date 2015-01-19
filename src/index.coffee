redis = require 'redis'
{EventEmitter} = require 'events'
async = require 'async'


# Is Event Emitter with following Events:
#		error
#		connected
#		message
module.exports = class ShackHeraldClient extends EventEmitter
	# takes the config object:
	#	{
	#		redis: {host, port}
	#		
	#	}
	constructor: (@config) ->
		@sub = redis.createClient config.redis.port, config.redis.host
		@pub = redis.createClient config.redis.port, config.redis.host

		# resolve ECONNREFUSED for the user?
		# onError = (err) ->
		# 	if err.message.indexOf 'ECONNREFUSED' > 0
		# 		log.warn "can't reach redis", err
		# 	else
		# 		log.err err.message

		@sub.on 'error', (err) => @emit 'error', err
		@pub.on 'error', (err) => @emit 'error', err

		@sub.on 'subscribe', (channel, count) =>
			@emit 'connected', channel, count

		@sub.on 'message', (channel, message) =>
			try
				parsedMessage = JSON.parse message
			catch
				@emit 'error', "cannot parse message \"#{message}\""
			@emit 'message', parsedMessage

		@sub.subscribe "announce"

		publish: (message) =>
			if typeof(message) is 'string'
				message =
					content: message
			@pub.publish 'announce', JSON.stringify message