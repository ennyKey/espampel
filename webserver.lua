function sendWebPage(conn,answertype)
	buf="HTTP/1.1 200 OK\nServer: NodeMCU\nContent-Type: text/html\n\n"
	buf = buf .. "<html><body>\n"
	buf = buf .. "<h1>Welcome to the Camp-Ampel</h1>"
    buf = buf .. "<div style=\"background-color:#000; display:inline-block;\">"
	if gpio.read(red) == 1 then
		--buf = buf .. "<button onclick=\"location.ref='/red=off';\">Rot: " .. gpio.read(red) .. "</button><br/>"
        buf = buf .. "<div onclick=\"javascript:location.href='?red=off'\" style=\"width: 3em; height:3em; background-color:#f00;border-radius:1.5em;margin:0.4em;\"></div>"
	else
		--buf = buf .. "<button onclick=\"location.ref='/red=on';\">Rot: " .. gpio.read(red) .. "</button><br/>"
        buf = buf .. "<div onclick=\"javascript:location.href='?red=on'\" style=\"width: 3em; height:3em; background-color:#300;border-radius:1.5em;margin:0.4em;\"></div>"
	end
	if gpio.read(yellow) == 1 then
		--buf = buf .. "<button onclick=\"location.ref='/yellow=off';\">Gelb: " .. gpio.read(yellow) .. "</button><br/>"
        buf = buf .. "<div onclick=\"javascript:location.href='?yellow=off'\" style=\"width: 3em; height:3em; background-color:#fd0;border-radius:1.5em;margin:0.4em;\"></div>"
	else
		--buf = buf .. "<button onclick=\"location.ref='/yellow=on';\">Gelb: " .. gpio.read(yellow) .. "</button><br/>"
        buf = buf .. "<div onclick=\"javascript:location.href='?yellow=on'\" style=\"width: 3em; height:3em; background-color:#220;border-radius:1.5em;margin:0.4em;\"></div>"
	end
	if gpio.read(green) == 1 then
		--buf = buf .. "<button onclick=\"location.ref='/green=off';\">Grün: " .. gpio.read(green) .. "</button><br/>"
        buf = buf .. "<div onclick=\"javascript:location.href='?green=off'\" style=\"width: 3em; height:3em; background-color:#00f;border-radius:1.5em;margin:0.4em;\"></div>"
	else
		--buf = buf .. "<button onclick=\"location.ref='/green=on';\">Grün: " .. gpio.read(green) .. "</button><br/>"
        buf = buf .. "<div onclick=\"javascript:location.href='?green=on'\" style=\"width: 3em; height:3em; background-color:#002;border-radius:1.5em;margin:0.4em;\"></div>"
	end
    buf = buf .. "</div>"
	buf = buf .. "\n</body></html>"
	conn:send(buf)
	buf=nil
end

function startWebServer()
	srv=net.createServer(net.TCP)
	srv:listen(80,function(conn)
		conn:on("receive", function(conn,payload)
			if (payload:find("GET /red=on") ~= nil) then
				--here is code for handling http request from a web-browser
				gpio.write(red,gpio.HIGH)
				sendWebPage(conn,1)
				conn:on("sent", function(conn) conn:close() end)	
			elseif (payload:find("GET /red=off") ~= nil) then
				gpio.write(red,gpio.LOW)
				sendWebPage(conn,1)
				conn:on("sent", function(conn) conn:close() end)
			elseif (payload:find("GET /yellow=on") ~= nil) then
				gpio.write(yellow,gpio.HIGH)
				sendWebPage(conn,1)
				conn:on("sent", function(conn) conn:close() end)
			elseif (payload:find("GET /yellow=off") ~= nil) then
				gpio.write(yellow,gpio.LOW)
				sendWebPage(conn,1)
				conn:on("sent", function(conn) conn:close() end)
			elseif (payload:find("GET /green=off") ~= nil) then
				gpio.write(green,gpio.LOW)
				sendWebPage(conn,1)
				conn:on("sent", function(conn) conn:close() end)
			elseif (payload:find("GET /green=on") ~= nil) then
				gpio.write(green,gpio.HIGH)
				sendWebPage(conn,1)
				conn:on("sent", function(conn) conn:close() end)	
			else
			--here is code, if the connection is not from a webbrowser, i.e. telnet or nc
				global_c=conn
				function s_output(str)
					if(global_c~=nil)
					then global_c:send(str)
					end
				end
				node.output(s_output, 0)
				global_c:on("receive",function(c,l)
					node.input(l)
				end)
				global_c:on("disconnection",function(c)
					node.output(nil)
					global_c=nil
				end)
				print("Welcome to WS2812Ambi CLI")

			end
		end)
		conn:on("disconnection", function(c)
			node.output(nil)        -- un-register the redirect output function, output goes to serial
		end)
	end)
end
