local OrdNum = {}
local ExchNum = {}
local TradeNum = {}

function StrParser(strBuf, delimited)
	local First = string.find(strBuf, delimited)
	local List = {}
	local Index = 1
	local Next = nil
	if First then
		List[Index] = string.sub(strBuf, 1, First-1)
		Index = Index +1
		Next = string.find(strBuf, delimited, First+1)
		while Next do
			List[Index] = string.sub(strBuf, First+1, Next-1)
			Index = Index +1
			First = Next
			Next = string.find(strBuf, delimited, First+1)
		end
		
		if First then
			List[Index] = string.sub(strBuf, First+1, -1)
		end
	end
	
	--[[
	if First then
		List[Index] = string.sub(strBuf, 1, Next-1)
		Index = Index +1
		
		Next = string.find(strBuf, delimited, First+1)
		if Next then
			List[Index] = string.sub(strBuf, First+1, Next-1)
			First = Next
			Next = string.find(strBuf, delimited, First+1)
			Index = Index +1
		end
	
		while First do	
			if Next then
				List[Index] = string.sub(strBuf, First+1, Next-1)
				First = Next
				Index = Index + 1
				Next = string.find(strBuf, delimited, First+1)
			else
				List[Index] = string.sub(strBuf, First+1, -1)
				break
			end
		end
	end
	--]]
	return List
end

-- Parse data to store in map. 
function ParserToMapList(strBuf, delimited)
	local MapList = {}
	local ArrResult = StrParser(strBuf, delimited)
	if ArrResult then
		for i, v in pairs(ArrResult) do
			if i % 2 == 0 then
				MapList[tostring(ArrResult[i-1])] = v
			else
				MapList[tostring(v)] = nil
			end
		end
	end
	return MapList
end


function IsExistOrdNum(OrderNum)
	local i,j = pairs(OrderNum)
		if i == OrderNum then
			return true
	end
	return false
end

function IsExistExchNum(ExchOrdNum)
	local i,j = pairs(ExchNum)
		if i == ExchOrdNum then
			return true
	end
	return false
end

function IsExistTradeNum(TradeNum)
	local i,j = pairs(TradeNum)
		if i == TradeNum then
			return true
	end
	return false
end

function Analysis(strExchOrd)
local i,j = string.find(strExchOrd, 'SUBORDER_SEHK|')
	if i then
		local substr = string.sub(strExchOrd, j+1, -1)
		local list = ParserToMapList(substr, "|")
		if list then
			--local tmpOrdNum = List['6']
			local tmpExchNum = List["7"]
			if (tmpOrdNum and not IsExistExchNum(tmpOrdNum)) then
			--for m, n in pairs(List) do
				print(tmpOrdNum)
			end
		end
	end
end

function StartSplitFile(arg)
	if arg then
		local FileName  = arg[1]
		FileHandle = io.open(FileName, "rb")
		if FileHandle ~= nil then
			for linestr in FileHandle:lines() do
				Analysis(linestr)
			end
			FileHandle:close()
		else
			print("could not open file:" .. FileName)
		end
	end
end

--arg = {"D:\\Working\\OCG\\Src\\OCGLink_1.0.2.12_Src\\1.0.2.12\\oms_c\\Bin\\Release\\log\\ocglog.txt"}
revDays = {["Sunday"] = 1, ["Monday"] = 2, 
                     ["Tuesday"] = 3, ["Wednesday"] = 4,
                     ["Thursday"] = 5, ["Friday"] = 6,  
                     ["Saturday"] = 7} 


arg = {"D:\\MyProgram\\luascript\\ocglog_1.txt"}
StartSplitFile(arg)
