--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/6/10
-- Time: 10:49
-- 用于网络数据操作
--

_G.LOGIN_SERVER = "acc_server"
_G.GATEWAY_SERVER = "gateway_server"


_G.PACKET_HEAD = (0x52FA) -- magic

_G.PARSEING_FIRST = 1
_G.PARSEING_HEADERS = 2
_G.PARSEING_BODYS = 3
_G.PARSER_NONE = 4
_G.MAX_BODY_LEN = 204800
_G.COMPRESS_THRESHOLD = 128
_G.netSended = 0
_G.netRecved = 0
_G.netIndex = 1
_G.lastCheckNetSended = 0
_G.lastCheckNetRecved = 0
_G.classlist['ConnManager'] = 'ConnManager'
_G.ConnManager  = {}
_G.ConnManager.objName = 'ConnManager'
ConnManager.connList = {}   -- 所有连接
ConnManager.protoHandler = {}  -- 所有callback list
ConnManager.readTimeout = 1200  -- 1200 second timeout
ConnManager.reConnTimeout = 3000000 -- 3s
ConnManager.connected = false;
ConnManager.gateServer = nil --connsrv || crossserver
ConnManager.showPopUp = true
_G.NOT_NET_RECEIVE = true

_G.ConnManager.encrypt_key = {
    0x17, 0xa1, 0x93, 0x37, 0xf2,
    0x60, 0xe9, 0x9e, 0x0e, 0x79,
    0xe0, 0x16, 0x09, 0x7e, 0xe7,
    0x52, 0x1d, 0x6e, 0xf3, 0x84,
    0x1a, 0x6d, 0xf4, 0x84, 0x13,
    0x34, 0xed, 0x8a, 0x14, 0x23}

_G.ConnManager.encrypt_key_len = #_G.ConnManager.encrypt_key

function ConnManager:encrypt_packet(data, len)
	local ret = ""
	local i = 1
	while i <= len do
		local o = string.byte(data, len - i + 1)
		o = bit.bxor(o, self.encrypt_key[((i + len - 1) % self.encrypt_key_len) + 1])
		ret = ret .. string.char(o)
		i = i + 1
	end
	return ret
end

function ConnManager:decrypt_packet(data, len)
	local ret = ""
	local i = 1
	while i <= len do
		local o = string.byte(data, len - i + 1)
		o = bit.bxor(o, self.encrypt_key[((len - i + len) % self.encrypt_key_len) + 1])
		ret = ret .. string.char(o)
		i = i + 1
	end
	return ret
end

function ConnManager:checksum_packet(seed, data, len)
	local ret = 0
	local i = 1
	while i <= len do
		local o = string.byte(data, i)
		local pos = ((seed + o + len) % self.encrypt_key_len) + 1
		ret = bit.bxor(ret, self.encrypt_key[pos])
		i = i + 1
	end
	return ret
end

--local zipTime = 0
--local unzipTime = 0
function ConnManager:addHandler(msgId, obj, callback)
    self.protoHandler[msgId] = {fm = obj, cb = callback}
end

local rawBytes;
local tmpRawBytes;
local tmpdata;
function ConnManager:netSend(net, msgId, data)
	--local now0 = os.now( 0.001 )
    if net then
        rawBytes = string.from16l(PACKET_HEAD)
        --Debug("Send Msgid: " .. msgId)
		
		tmpRawBytes = string.from16l(_G.netIndex)
		tmpdata = tmpRawBytes..data
		tmpRawBytes = string.from16l(msgId)
		tmpdata = tmpRawBytes..tmpdata
		local randseed = math.random(255)
		local checksum = self:checksum_packet(randseed, tmpdata, #tmpdata)
		
		local dataSize = #data
        --Debug("i8guid: ", _G.m_guid)
        if data ~= nil then
		
            --Debug("dataSize: " .. (#data))
            if dataSize > _G.COMPRESS_THRESHOLD then
                --print('zipping')
                --local now0 = os.now( 0 )
                data = _deflate(data)
                --local now1 = os.now( 0 )
                --print('zipping', now1, now0, #data, dataSize)
                --zipTime = zipTime + now1 - now0;
                tmpRawBytes = string.from32l(#data)
				rawBytes = rawBytes .. tmpRawBytes
				tmpRawBytes = string.char(randseed)
				rawBytes = rawBytes .. tmpRawBytes
				tmpRawBytes = string.char(checksum)
				rawBytes = rawBytes .. tmpRawBytes
                tmpRawBytes = string.from32l(dataSize)
				rawBytes = rawBytes .. tmpRawBytes
				
				-- 压缩的单独加密下
				tmpdata = string.from16l(msgId)
				tmpRawBytes = string.from16l(_G.netIndex)
				tmpdata = tmpdata..tmpRawBytes
				tmpdata = self:encrypt_packet(tmpdata, #tmpdata)
				rawBytes = rawBytes .. tmpdata
				
				data = self:encrypt_packet(data, #data)
				rawBytes = rawBytes .. data
            else
                tmpRawBytes = string.from32l(#data)
				rawBytes = rawBytes .. tmpRawBytes
				tmpRawBytes = string.char(randseed)
				rawBytes = rawBytes .. tmpRawBytes
				tmpRawBytes = string.char(checksum)
				rawBytes = rawBytes .. tmpRawBytes
                tmpRawBytes = string.from32l(0)
				rawBytes = rawBytes .. tmpRawBytes
				
				tmpdata = self:encrypt_packet(tmpdata, #tmpdata)
				rawBytes = rawBytes .. tmpdata
            end

        else
            --Debug("dataSize: " .. "0")
			--assert(false) 
            tmpRawBytes = string.from32l(0)
			rawBytes = rawBytes .. tmpRawBytes
			tmpRawBytes = string.from8l(randseed)
			rawBytes = rawBytes .. tmpRawBytes
			tmpRawBytes = string.from8l(checksum)
			rawBytes = rawBytes .. tmpRawBytes
			tmpRawBytes = string.from32l(0)
			rawBytes = rawBytes .. tmpRawBytes
			
			tmpdata = self:encrypt_packet(tmpdata, #tmpdata)
			rawBytes = rawBytes .. tmpdata
        end
		sendn(net, rawBytes, 0, #rawBytes)
		_G.netIndex = _G.netIndex + 1
		if _G.netIndex > 9999 then
			_G.netIndex = 1
		end
        --Debug("ConnManager: ")
    end
	--local now1 = os.now( 0.001 )
	--Debug("NetSend: ", now1, now0, now1 - now0)

end


local RE_SEND_GAP = 100
local lastReSendTime = 0;
function sendn(net, data, begin, to)
    if ConnManager.connected == false then return; end
	local sended = net:send(data, begin, to, true)
    if sended < to then -- OS 缓冲区Full, we don't want let engine close net. so... FUCK CODE
		lastReSendTime = GetCurTime()
		while(true)
		do
			if (GetCurTime() - lastReSendTime) > RE_SEND_GAP then
				sendn(net, data, sended, to)
				break
			end
        end
		local errMsg = "fuck send buffer full: " .. '|' .. sended .. '|' .. to
		_debug:throwException(errMsg)
		Debug("send buffer full, check point: ", sended, to)
    end
	_G.netSended = _G.netSended + (to - begin)
end

function ConnManager:send(msgId, data)
    if self.connected == false then return; end
    self:netSend(ConnManager.gateServer, msgId, data)
end

function _G.g_connecServer(to, onInit, onConnect, reconnect)
	_G.netIndex = 1
    ConnManager:connectServer(to, onInit, onConnect, reconnect)
end

if _G.isDebug then
	_G.bigMsg = _File.new()
	bigMsg:create("bigMsg.log",'w')
end
function ConnManager:connectServer(to, onInit, onConnect, reconnect)
    --local onHead, onBody
    local serviceState
    local msgid
    local datasize = 0
    local i8guid
	local randseed
	local checksum
	local compress
    local onBody, onHead
    local last = 0
    local delt = 0

    function onBody(net, data)
		if data ~= nil then
			data = self:decrypt_packet(data, string.len(data))
		end
		if compress ~= 0 then
			--print('unzipping')
			--local now0 = os.now( 0 )
			if data ~= nil then
				data = _inflate(data, compress)
			end
			--local now1 = os.now( 0 )
			--print('unzipping', now1, now0, #data, dataSize)
			--unzipTime = unzipTime + now1 - now0;
		end
		
		local executed = false;
		local event = self.protoHandler[msgid];
		if event then
			local fm = event.fm;
			local callback = event.cb
			callback(fm, data)
			callback = nil
			executed = true;
		end
		
		if MsgManager:HandleMsg(msgid,data) then
			executed = true;
		end
		
		if not executed then
			Debug("Warning.未处理的消息:",  msgid)
		end
		
        serviceState = PARSEING_FIRST
        if NOT_NET_RECEIVE then
			_G.netRecved = _G.netRecved + 2;
            net:receive(2, onHead, ConnManager.readTimeout)
        end
    end

    function onHead(net, data)
        local datastr = data:tostr()

        if serviceState == PARSEING_FIRST then
            local begin = string.to16l(data, 1, true)
            serviceState = PARSEING_HEADERS
            if NOT_NET_RECEIVE then
				_G.netRecved = _G.netRecved + 14;
                net:receive(14, onHead, ConnManager.readTimeout)
            end
        elseif serviceState == PARSEING_HEADERS then
            msgid = data:to16l(11, true)
            datasize = data:to32l(1, true)
            compress = data:to32l(7, true)
			--print("compress", compress)
            serviceState = PARSEING_BODYS
            if datasize < 0 or datasize > MAX_BODY_LEN then
                Error("datasize error ")
                net:close()
				_debug:throwException("connmanager max body.msgid "..msgid .. " MsgBuildVersion " .. _G.MsgBuildVersion .. " datasize " .. datasize);
            elseif datasize == 0 then
                onBody(net, nil)
            else
				if _G.isDebug then
					if datasize > 4096 then
						bigMsg:write("msgId: " .. msgid .. "c: " .. compress .. "size: " .. datasize .. "\r\n")
					end
				end
                if NOT_NET_RECEIVE then
					_G.netRecved = _G.netRecved + datasize;
                    net:receive(datasize, onBody, ConnManager.readTimeout)
                end
            end
        end

    end

    Debug('connecting', to)
    onInit(_connect(to, function(net)
        Debug('connected ', to) 
		UIConfirm:Close(self.confirmid);--如果 连接超时,重连中... UIConfirm已弹出，要关掉UIConfirm
        self.connected = true
		net:nagle(false) --关闭延迟发送 AKA NO_DELAY
        serviceState = PARSEING_FIRST
        if NOT_NET_RECEIVE then
			_G.netRecved = _G.netRecved + 2;
            net:receive(2, onHead, 60 * 60) --  second timeout
        end
        onConnect(net)
    end, function(net, timeout, notconn, err)
        if notconn then
            Debug('connect failed', to, timeout, notconn, err)
            self.confirmid = UIConfirm:Open(StrConfig['login41']);
            if reconnect then
                _enqueue(os.now(0) + ConnManager.reConnTimeout, nil, g_connecServer, to, onInit, onConnect, reconnect)
            end
        else
			if self.showPopUp then
				UIConfirm:Open(StrConfig['login42'],backLoginPage,backLoginPage);
				Debug('close', to, timeout, notconn, err)
			end
            self.connected = false
            			
        end
    end, 3)) -- 3 second timeout
end

function ConnManager:close()
	if self.gateServer then
		self.gateServer:close();
		self.gateServer = nil
		Debug("ConnManager:close()");
	end
	
end

--[[
    typedef struct _packet_base_st
    {
        short       m_i2Begin;
        short       m_i2PacketID;
        int       	m_i2DataSize;
        int      	m_i4Compress;
		
        char        m_szData[0];
        _packet_base_st()
        {
            memset(this, 0, sizeof(*this));
        }
    }EventNetPacket;
]]
