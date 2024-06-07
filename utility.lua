-----------------------------------------------------------------------------
-- utility stuff
-----------------------------------------------------------------------------
--module("utils")
local util = {}

-- Parse data to store in vector.
function util.StrParser(strBuf, delimited)
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
function util.ParserToMapList(strBuf, delimited)
	local MapList = {}
	local tMap = {}
	local ArrResult = util.StrParser(strBuf, delimited)
	if ArrResult then
		for i, v in pairs(ArrResult) do
			if i % 2 == 0 then
				local num = tonumber(ArrResult[i-1]) 
				if num then
					MapList[num] = v
				end
			end
		end
	end
	return MapList
end

--[[
local strText = "[20180409 09:34:12.026][ThreadID: 1756]ORD>|quote|0|HB1J8|74|CQ110010|2001|98.990000|2002|99.090000|2007|5|2008|5|46|13|13|JONATHAN|10|CNH01|33|09:36:04|"
local ActStr = {"ORD>|quote|"}
for k, v in pairs(ActStr) do
	local i,j = string.find(strText, v)
	if i then
		local substr = string.sub(strText, j+1, -1)
		local List = ParserToMapList(substr, "|")
		if List then
			for m, n in pairs(List) do
				print(n)
			end
		end
	end
end
--]]

return util