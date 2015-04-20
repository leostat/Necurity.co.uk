-- Modified By Alexander Innes 2015 
-- https://necurity.co.uk
--
-- Originally by
-- Copyright (C) 2012 Trustwave
-- http://www.trustwave.com
-- 
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 dated June, 1991 or at your option
-- any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
-- 
-- A copy of the GNU General Public License is available in the source tree;
-- if not, write to the Free Software Foundation, Inc.,
-- 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

description = [[
Gets a screenshot from the host
]]

author = "Alex Innes <senni at necurity>"

license = "GPLv2"

categories = {"discovery", "safe"}

-- Updated the NSE Script imports and variable declarations
local shortport = require "shortport"

local stdnse = require "stdnse"

portrule = shortport.http

action = function(host, port)
	-- Check to see if ssl is enabled, if it is, this will be set to "ssl"
	local pssl = shortport.ssl(host,port)

	-- The default URLs will start with http://
	local prefix = "http"

	if (host.targetname) then
	-- Screenshots will be called screenshot-namp-<IP>:<port>.png
        	scantarget = host.targetname
	else
	-- There is no hostname eep
		scantarget = host.ip
	end

	-- Set the filename
	filename = "screenshot-nmap-"..scantarget.."."..port.number..".png"

	-- If SSL is set on the port, switch the prefix to https
	if pssl then
		prefix = "https"	
	end

	-- Execute the shell command wkhtmltoimage-i386 <url> <filename>
	local cmd = "wkhtmltoimage -n " .. prefix .. "://" .. scantarget .. ":" .. port.number .. " " .. filename .. " 2> /dev/null   >/dev/null"
	
	local ret = os.execute(cmd)
	-- If the command was successful, print the saved message, otherwise print the fail message
	local result = "Fail :( (Is wkhtmltoimage in path | Is the service not detecting SSL | Is it a bad return code?) \n   * I tried do do this : "..cmd

	if ret then
		result = "Saved to " .. filename
	end

	-- Return the output message
	return stdnse.format_output(true,  result)

end
