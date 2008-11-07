require 'hid'

class Wiimote
	# a? ‚Æ‚©‚Ì‚Ù‚¤‚ª‚¢‚¢‚©‚È‚ 
	attr_reader :a, :b, :up, :down, :left, :right, :plus, :minus, :one, :two, :home
	attr_reader :xaxis, :yaxis, :zaxis

	def initialize
		@wiimote = Hid.new( 0x057e, 0x0306 )
		@xaxis = 0
		@yaxis = 0
		@zaxis = 0
	end
	
	#
	# http://www.wiili.org/index.php/Wiimote#Motion_Sensor
	#
	def motion_sensor( enable = true )
		@wiimote.write( [ 0x12, 0x00, enable ? 0x31 : 0x30 ].pack( 'C*' ) )
	end
	
	def enable_motion_sensor
		motion_sensor( true )
	end
	
	def disable_motion_sensor
		motion_sensor( false )
	end
	
	
	#
	# http://www.wiili.org/index.php/Wiimote#Player_LEDs
	#
	def change_led_state( one = false, two = false, three = false, four = false )
		data = 0
		data += 0b00010000 if one
		data += 0b00100000 if two
		data += 0b01000000 if three
		data += 0b10000000 if four
		
		@wiimote.write( [ 0x11, data ].pack( 'C*' ) )
	end
	
	alias :led_out :change_led_state
	
	# 
	# http://www.wiili.org/index.php/Wiimote#Rumble
	#
	def rumble( activate )
		@wiimote.write( [ 0x13, activate ? 0x01 : 0x00 ].pack( 'C*' ) )
	end
	
	# 
	# http://www.wiili.org/index.php/Wiimote#Buttons
	#
	def update
		loop {
			data = @wiimote.read
			break if data.empty?
			
			next unless ( data[0] & 0x30 ) == 0x30
			
			@left  = ( data[1] & 0x01 ) == 0x01
			@right = ( data[1] & 0x02 ) == 0x02
			@down  = ( data[1] & 0x04 ) == 0x04
			@up    = ( data[1] & 0x08 ) == 0x08
			@plus  = ( data[1] & 0x10 ) == 0x10
			
			@two   = ( data[2] & 0x01 ) == 0x01
			@one   = ( data[2] & 0x02 ) == 0x02
			@b     = ( data[2] & 0x04 ) == 0x04
			@a     = ( data[2] & 0x08 ) == 0x08
			@minus = ( data[2] & 0x10 ) == 0x10
			@home  = ( data[2] & 0x80 ) == 0x80
			
			next unless ( data[0] & 0x31 ) == 0x31
			
			@xaxis = data[3]
			@yaxis = data[4]
			@zaxis = data[5]
		}
	end
	
	# 
	# http://www.wiili.org/index.php/Wiimote#Speaker
	#
=begin
	def speaker( activate = true )
		@wiimote.write( [ 0x14, activate ? 0x04 : 0x00 ].pack( 'C*' ) )
	end
	
	def enable_speaker
		speaker( true )
	end
	
	def disable_speaker
		speaker( false )
	end
	
	def mute( on = true )
		@wiimote.write( [ 0x19, activate ? 0x04 : 0x00 ].pack( 'C*' ) )
	end
=end
end
