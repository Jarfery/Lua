local BufSize = 2^16	-- BufSize is 64K

local KiloByte = 2^10	-- 1 KB
local MegaByte = 2^20	-- 1 MB
local GigaByte = 2^30	-- 1 GB

local ByteUnit = {["KB"] = KiloByte, ["MB"] = MegaByte, ["GB"] = GigaByte}

local SplitSize = MegaByte		-- Split Size default value is 1MB

function GetFileSize(Fhandle)
	local current = Fhandle:seek()     -- get current position
    local size,msg = Fhandle:seek("end")   -- get file size
    Fhandle:seek("set", current)       -- restore position
	
    return size
end

function length_of_file(filename)
	local fh = assert(io.open(filename,"rb"))
	local len = assert(fh:seek("end"))
	fh:close()
	print("length of file:"..filename..len)
	return len
end

function GetSplitFileTable(FHandle, strNewName)
	-- Get the file size which to be splited
	local nFileSize = GetFileSize(FHandle)
	if not nFileSize then
		print("Failed to get file size")
		return
	end
	print("FlieSize:"..nFileSize)
	local nFileCount = nFileSize / SplitSize
	if nFileSize % SplitSize then
		nFileCount = nFileCount + 1
	end

	print("FileCount:"..nFileCount)
	-- constructed a table to stored the splite file name
	local TabFileName = {}
	for i = 1, nFileCount do
		TabFileName[i] = string.format('%s_%d.txt', strNewName, i)
		print("FileName["..i.."]:"..TabFileName[i])
	end
	
	return TabFileName
end

--[[
function GetSplitFileTable(strFileName, strNewName, nSpliteSize)
	--local Filehandle, msg = assert(io.open(strFileName, "rb"), "invalid file path")
	local Filehandle = io.open(strFileName, "rb")
	if Filehandle ~= nil then
			-- Get the file size which to be splited
		local nFileSize = GetFileSize(Filehandle)
		local nFileCount = nFileSize / nSpliteSize
		if nFileSize % nSpliteSize then
			nFileCount = nFileCount + 1
		end
		
		Filehandle:close()	--	close the file
		
		-- constructed a table to stored the splite file name
		local TabFileName = {}
		for i = 1, nFileCount do
			TabFileName[i] = string.format('%s_%d', strNewName, i)
		end
		
		return TabFileName
	else
		print(string.format("could not open file name : %s\n", strFileName))
		return nil
	end
end

--]]

--[[
function SplitFile(strFileName, TabFileName)
	assert(SplitSize > 0)

	local Fhandle = io.open(strFileName, "rb")
	if FHandle == nil then
		print(string.format("could not open file name : %s", strFileName))
		return
	end

	local strLeaveBuf = ""
	-- Split file 
	for _,value in pairs(tabFileName) do
		local nWriteSize = 0
		local TmpFhandle = io.open(value, "wb")
		if TmpFhandle ~= nil then
			-- first to write the leave buf which the last file over the max filesize
			local nLeaveSize = strnig.len(strLeaveBuf)
			if nLeaveSize > 0 then
				TmpFhandle:write(strLeaveBuf)
				nWriteSize = nWriteSize + nLeaveSize
			end;
			
			-- Begin to write the split file
			while true do
				local strBuf = Fhandle:read(BufSize)
				local nReadSize = string.len(strBuf)
				nWriteSize = nWriteSize + nReadSize
				if nWriteSize > SplitSize then
					local nPos = 0
					local nTmpSize = nWriteSize - nReadSize
					while true do
						local i,j = string.find(strBuf, "\n", nPos+1)
						nPos = nPos + (j or 0)
						if j == nil then
							TmpFhandle:write(strBuf)
							nTmpSize = nTmpSize + nReadSize
							nWriteSize = nTmpSize
							
							-- if no found the specified string, but the file size is larger than MaxFileSize,
							-- then break the loop 
							if nWriteSize >= SplitSize then
								break
							end
							
							strBuf = Fhandle:read(BufSize)							
						elseif nTmpSize + nPos >= nWriteSize then
							local TmpBuf = string.sub(strBuf, 1, nPos)
							strLeaveBuf = string.sub(strBuf, nPos+1, -1)
							TmpFhandle:write(TmpBuf)
							nWriteSize = nTmpSize + string.len(TmpBuf)
							break
						end
					end;					
					break
				else
					TmpFhandle:write(strBuf)
				end;
			end;
			
			TmpFhandle:close()
		end
	end
end

--]]

function SplitFile(FHandle, TabFileName)
	local strLeaveBuf = ""
	-- Split file 
	for _,value in pairs(TabFileName) do
		local nWriteSize = 0
		local TmpFhandle = io.open(value, "wb")
		if TmpFhandle ~= nil then
			-- first to write the leave buf which the last file over the max filesize
			local nLeaveSize = string.len(strLeaveBuf)
			if nLeaveSize > 0 then
				TmpFhandle:write(strLeaveBuf)
				nWriteSize = nWriteSize + nLeaveSize
			end;
			
			-- Begin to write the split file
			while true do
				local strBuf = FHandle:read(BufSize)
				if strBuf == nil then
					break
				end
				
				local nReadSize = string.len(strBuf)
				nWriteSize = nWriteSize + nReadSize
				if nWriteSize > SplitSize then
					local nPos = 0
					local nTmpSize = nWriteSize - nReadSize
					while true do
						local i,j = string.find(strBuf, "\n", nPos+1)
						nPos = nPos + (j or 0)
						if j == nil then
							TmpFhandle:write(strBuf)
							nTmpSize = nTmpSize + nReadSize
							nWriteSize = nTmpSize
							
							-- if no found the specified string, but the file size is larger than MaxFileSize,
							-- then break the loop 
							if nWriteSize >= SplitSize then
								break
							end
							
							strBuf = FHandle:read(BufSize)							
						elseif nTmpSize + nPos >= SplitSize then
							local TmpBuf = string.sub(strBuf, 1, nPos)
							strLeaveBuf = string.sub(strBuf, nPos+1, -1)
							TmpFhandle:write(TmpBuf)
							nWriteSize = nTmpSize + string.len(TmpBuf)
							break
						end
					end;					
					break
				else
					TmpFhandle:write(strBuf)
				end;
			end;
			
			TmpFhandle:close()
		end
	end
end

function StartSplitFile(arg)
	if arg then
		local nUnit = 1
		local FileName, newFile, nSize, Unit = table.unpack(arg)
		--local FileName, newFile, nSize, Unit = unpack(arg)
		if ByteUnit[Unit] then
			nUnit = ByteUnit[Unit]
			print("Unit:"..nUnit)
		end
				
		if FileName then
			--Just for test function
			length_of_file(FileName)
			-- end of test function
			local Filehandle = io.open(FileName, "rb")
			if Filehandle then
			print("open file:"..FileName.."success")
				newFile = newFile or "tmp_part_"
				SplitSize = (nSize or 1) * nUnit
				print("Splite Size:"..SplitSize)
				local TabFileName = GetSplitFileTable(Filehandle, newFile)
				if TabFileName ~= nil then
					SplitFile(Filehandle, TabFileName)

					for i, k in pairs(TabFileName) do
						print(k)
					end
				end	
			end
		end
		--[[
		local TabFileName = GetSplitFileTable(FileName, newFile, nSize)
		SplitSize = nSize
		if TabFileName ~= nil then
			for i, k in pairs(TabFileName) do
				SplitFile(FileName, TabFileName)
			end
		end	
		--]]
	end
end

function DoTestArg(arg)
--[[	if arg then
		for i, k in pairs(arg) do
			if k ~= nil then
				print(string.format("arg#%d %s\n", i, k))
			else
				print("not value in arg")
			end
		end
	end
	--]]
	if arg then
		local FileName, newFile, nSize = table.unpack(arg)
		if FileName ~= nil then
			print(FileName)
		end
		if newFile ~= nil then
			print(newFile)
		end
		if nSize ~= nil then
			print(nSize)
		end
	end
end

--arg = {"OMDStaticDataFile.txt"; "tmp_part_"; 1.5, "GB"}
--arg = {"C:\\Users\\jarferydu\\Desktop\\Support\\RHB\\20180626\\OMDDump.txt";"C:\\Users\\jarferydu\\Desktop\\Support\\RHB\\20180626\\tmp_part";"512";"MB"}
StartSplitFile(arg)
--DoTestArg(arg)