local sock = require("socket")
--local host = "127.0.0.1"
local host = "localhost"
local port = "9994"
--local port = "9101"

function InitSock(svrHost, svrPort)
	if svrHost then
		 host = svrHost
	end
	if svrPort then
		 port = svrPort
	end

	local server = assert(sock.bind(host, port, 1024))
	server:settimeout(0)
	local client_tab = {}
	local conn_count = 0
	print("Server Start " .. host .. ":" .. port) 
 
	while 1 do
		local conn = server:accept()
		if conn then
			conn_count = conn_count + 1
			client_tab[conn_count] = conn
			print("A client successfully connect!") 
		end
  
		for conn_count, client in pairs(client_tab) do
			local recvt, sendt, status = sock.select({client}, nil, 1)
			if #recvt > 0 then
				local receive, receive_status = client:receive()
				if receive_status ~= "closed" then
					if receive then
						assert(client:send("Client " .. conn_count .. " Send : "))
						assert(client:send(receive .. "\n"))
						print("Receive Client " .. conn_count .. " : ", receive)   
					end
				else
					table.remove(client_tab, conn_count) 
					client:close() 
					print("Client " .. conn_count .. " disconnect!") 
				end
			end       
		end
	end
end

InitSock(arg[1],arg[2])
