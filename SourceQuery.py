import socket, struct, sys, time, json

def main(addr='localhost', port=27015):
	try:
		query = SourceQuery(addr, port)
		data = {
			'info':query.get_info(),
			'players':query.get_players(),
			'rules':query.get_rules(),
		}
		query.disconnect()
		json.dump(data, open("/opt/server/query.json", "w"), sort_keys = False)
		if data['info'] == False:
			exit(1)
	except Exception as ex:
		print(ex)
		try:
			json.dump({
				'info':False,
				'players':[],
				'rules':False,
			}, open("/opt/server/query.json", "w"), sort_keys = False)
		except Exception as ex:
			print(ex)
		exit(1)

class SourceQuery(object):
	is_third = False
	__sock = None
	__challenge = None
	A2S_INFO = b'\xFF\xFF\xFF\xFFTSource Engine Query\x00'
	A2S_PLAYERS = b'\xFF\xFF\xFF\xFF\x55'
	A2S_RULES = b'\xFF\xFF\xFF\xFF\x56'
	S2A_INFO_SOURCE = chr(0x49)
	S2A_INFO_GOLDSRC = chr(0x6D)

	def __init__(self, addr, port=27015, timeout=5.0):
		self.ip, self.port, self.timeout = socket.gethostbyname(addr), port, timeout
		if sys.version_info >= (3, 0):
			self.is_third = True

	def disconnect(self):
		""" Close socket """
		if self.__sock is not None:
			self.__sock.close()
			self.__sock = False

	def connect(self):
		""" Opens a new socket """
		self.disconnect()
		self.__sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
		self.__sock.settimeout(self.timeout)
		self.__sock.connect((self.ip, self.port))

	def get_info(self):
		""" Retrieves information about the server including, but not limited to: its name, the map currently being played, and the number of players. """
		if self.__sock is None:
			self.connect()
		self.__sock.send(SourceQuery.A2S_INFO)
		try:
			data = self.__sock.recv(4096)
		except:
			return False

		data = data[4:]

		result = {}

		header, data = self.__get_byte(data)
		if chr(header) == SourceQuery.S2A_INFO_SOURCE:
			result['protocol'], data = self.__get_byte(data)
			result['name'], data = self.__get_string(data)
			result['map'], data = self.__get_string(data)
			result['folder'], data = self.__get_string(data)
			result['game'], data = self.__get_string(data)
			result['app'], data = self.__get_short(data)
			playerCount, data = self.__get_byte(data)
			playerMax, data = self.__get_byte(data)
			result['player'] = [playerCount, playerMax]
			result['bots'], data = self.__get_byte(data)
			dedicated, data = self.__get_byte(data)
			if chr(dedicated) == 'd':
				result['type'] = 'dedicated'
			elif chr(dedicated) == 'l':
				result['type'] = 'non-dedicated'
			elif chr(dedicated) == 'p':
				result['type'] = 'SourceTVproxy'
			else:
				result['type'] = False
			os, data = self.__get_byte(data)
			if chr(os) == 'w':
				result['os'] = 'windows'
			elif chr(os) in ('m', 'o'):
				result['os'] = 'mac'
			elif chr(os) == 'l':
				result['os'] = 'linux'
			else:
				result['os'] = False
			result['password'], data = self.__get_byte(data)
			result['vac'], data = self.__get_byte(data)
			if result['app'] == 2400:  # The Ship server
				result['GameMode'], data = self.__get_byte(data)
				result['WitnessCount'], data = self.__get_byte(data)
				result['WitnessTime'], data = self.__get_byte(data)
			result['version'], data = self.__get_string(data)
			edf, data = self.__get_byte(data)
			try:
				if edf & 0x80:
					result['port'], data = self.__get_short(data)
				if edf & 0x10:
					result['steamId'], data = self.__get_long_long(data)
				if edf & 0x40:
					result['spectator'] = {}
					result['spectator']['port'], data = self.__get_short(data)
					result['spectator']['name'], data = self.__get_string(data)
				if edf & 0x10:
					result['keywords'], data = self.__get_string(data)
				
				if edf & 0x01:
					result['gameID'], data = self.__get_long_long(data)
			except:
				pass
		elif chr(header) == SourceQuery.S2A_INFO_GOLDSRC:
			result['ip'], data = self.__get_string(data)
			result['Hostname'], data = self.__get_string(data)
			result['name'], data = self.__get_string(data)
			result['map'], data = self.__get_string(data)
			result['folder'], data = self.__get_string(data)
			result['game'], data = self.__get_string(data)
			playerCount, data = self.__get_byte(data)
			playerMax, data = self.__get_byte(data)
			result['player'] = [playerCount, playerMax]
			result['version'], data = self.__get_byte(data)
			dedicated, data = self.__get_byte(data)
			if chr(dedicated) == 'd':
				result['type'] = 'dedicated'
			elif chr(dedicated) == 'l':
				result['type'] = 'non-dedicated'
			elif chr(dedicated) == 'p':
				result['type'] = 'SourceTVproxy'
			else:
				result['type'] = False
			os, data = self.__get_byte(data)
			if chr(os) == 'w':
				result['os'] = 'windows'
			elif chr(os) == 'l':
				result['os'] = 'linux'
			else:
				result['os'] = False
			result['password'], data = self.__get_byte(data)
			result['is_mod'], data = self.__get_byte(data)
			if result['is_mod']:
				result['mod'] = {}
				result['mod']['link'], data = self.__get_string(data)
				result['mod']['download'], data = self.__get_string(data)
				data = self.__get_byte(data)[1]  # NULL-Byte
				result['mod']['version'], data = self.__get_long(data)
				result['mod']['size'], data = self.__get_long(data)
				result['mod']['type'], data = self.__get_byte(data)
				result['mod']['dll'], data = self.__get_byte(data)
			result['vac'], data = self.__get_byte(data)
			result['bot'], data = self.__get_byte(data)

		return result

	def get_challenge(self):
		# Get challenge number for A2S_PLAYER and A2S_RULES queries.
		if self.__sock is None:
			self.connect()
		self.__sock.send(SourceQuery.A2S_PLAYERS + b'0xFFFFFFFF')
		try:
			data = self.__sock.recv(4096)
		except:
			return False

		self.__challenge = data[5:]

		return True

	def get_players(self):
		# Retrieve information about the players currently on the server.
		if self.__sock is None:
			self.connect()
		if self.__challenge is None:
			self.get_challenge()

		try:
			self.__sock.send(SourceQuery.A2S_PLAYERS + self.__challenge)
		except TypeError:
			return False
		try:
			data = self.__sock.recv(4096)
		except:
			return False

		data = data[4:]

		header, data = self.__get_byte(data)
		#if chr(header) != 'D':
		#	print(chr(header), '!=', 'D')
		num, data = self.__get_byte(data)
		result = []
		try:
			for i in range(num):
				player = {}
				player['id'] = i + 1  # ID of All players is 0
				player['index'], data = self.__get_byte(data)
				player['name'], data = self.__get_string(data)
				player['score'], data = self.__get_long(data)
				player['duration'], data = self.__get_float(data)
				result.append(player)

		except Exception:
			pass

		return result

	def get_rules(self):
		""" Returns the server rules, or configuration variables in name/value pairs. """
		if self.__sock is None:
			self.connect()
		if self.__challenge is None:
			self.get_challenge()

		try:
			self.__sock.send(SourceQuery.A2S_RULES + self.__challenge)
		except TypeError:
			return False
		try:
			data = self.__sock.recv(4096)
			if data[0] == '\xFE':
				num_packets = ord(data[8]) & 15
				packets = [' ' for i in range(num_packets)]
				for i in range(num_packets):
					if i != 0:
						data = self.__sock.recv(4096)
					index = ord(data[8]) >> 4
					packets[index] = data[9:]
				data = ''
				for i, packet in enumerate(packets):
					data += packet
		except:
			return False
		data = data[4:]

		header, data = self.__get_byte(data)
		num, data = self.__get_short(data)
		result = {}

		# Server sends incomplete packets. Ignore "NumPackets" value.
		while 1:
			try:
				rule_value, data = self.__get_string(data)
				rule_name, data = self.__get_string(data)
				if rule_value:
					result[rule_value] = rule_name
			except:
				break

		return result

	def __get_byte(self, data):
		if self.is_third:
			return data[0], data[1:]
		else:
			return ord(data[0]), data[1:]

	def __get_short(self, data):
		return struct.unpack('<h', data[0:2])[0], data[2:]

	def __get_long(self, data):
		return struct.unpack('<l', data[0:4])[0], data[4:]

	def __get_long_long(self, data):
		return struct.unpack('<Q', data[0:8])[0], data[8:]

	def __get_float(self, data):
		return struct.unpack('<f', data[0:4])[0], data[4:]

	def __get_string(self, data):
		s = ""
		i = 0
		if not self.is_third:
			while data[i] != '\x00':
				s += data[i]
				i += 1
		else:
			while chr(data[i]) != '\x00':
				s += chr(data[i])
				i += 1
		return s, data[i + 1:]

if __name__ == '__main__':
	main( socket.gethostname(), int(sys.argv[1]) )
