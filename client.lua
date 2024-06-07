local g_socket = require("socket")
local g_host = "127.0.0.1"
local g_port = "9101"
--local clientSock = assert(socket.connect(host, port))
local g_clientSock = nil

function sleep( sec )
	g_socket.select(nil, nil, sec)
end
 
function InitSock(host, port)
	g_clientSock = assert(g_socket.connect(host, port))
	if g_clientSock ~= nil then
		print(string.format("connect to server:%s, port:%s", host, port))
	else
		print(string.format("cannot connect to server:%s, port:%s", host, port))
	end
end

function CloseSock()
	if g_clientSock ~= nil then
		g_clientSock:close()
	end
end

function IsComment(strvalue)
	local res = false
	if strvalue then
	   local _,index = string.find(strvalue,"#")
	   if index then
		res = true
	   end
        end   
	--[[if res then
		print("is comments string")
	else
		print("not a comments string")
	end
	--]]
	return res
end

function WaitTime(strValue)
	if strValue then
	   local _,index = string.find(strValue,"wait|")
	   if index then
	   	local subValue = string.sub(strValue, index+1, -1)
		_,index = string.find(subValue, "|")
		local timeValue = string.sub(subValue, 0, index - 1)
		--print("Parse wait cmd the time is:"..timeValue.."\n")
		print("Wait for "..timeValue.." second to continue...\n")
		sleep(tonumber(timeValue))
	   end
        end   
end

--[[
function TcpConnTest(host, port)
	-- body
	local count = 1
	while true do
	--while count < 3 do
		local client_1 = assert(socket.connect(host, port))
		local client_2 = assert(socket.connect(host, port))
		socket.sleep(1)
		client_1:close()
		client_2:close()
		count = count + 1
	end
	print("Total test connect & diconnect with DDS is "..count.." times")
end
--]]


function SendFileMsg(strFileName)
	if strFileName == nil then
		print("didn't get a valid file name to send msg, exit.\n")
		return
	end
	FileHandle = io.open(strFileName, "rb")
	if FileHandle == nil then
	   print("could not open append file:" .. FileAppend)
	   return
	end
	print("send msg file open success.\n")
	if g_clientSock ~= nil then		
	   for linestr in FileHandle:lines() do
	   	if linestr == nil then
	      	    print("no more msg to send, exit.\n")
	      	    break
	   	end;
	   
		WaitTime(linestr)
		if not IsComment(linestr) and string.len(linestr) > 0 then
			--print(linestr)
	   	    local _,index = string.find(linestr,">DDS|")
	    	    if index then
	      	    local substr = string.sub(linestr, index+1, -1)
  	      	    local sentbuf = g_clientSock:send(substr.."\n")
	      	
		    --print(substr)
	      	    --sleep(0.5)
	   	    else
  		    --g_clientSock:send(linestr)
  	      	    g_clientSock:send(linestr.."\n")
		    --print(linestr)
		    end;
	   	end;
	   end;--end of for loop
	   FileHandle:close()
	   print("close tcp socket.\n")
	else
	   print("client socket invalid.\n")
	end;
end

InitSock(arg[1], arg[2])
SendFileMsg(arg[3])
CloseSock()
--TcpConnTest(host, port)
