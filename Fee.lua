--local StamptaxRate = 0.001	--	stamp tax of equities
local StamptaxRate = 0.0005	--	stamp tax of equities reduce by half since 8/28/2023
local TransferFeeRate = 0.00001	--	stock transfer fee rate only for SHSE
--local TransferFeeRate = 0.0006	--	stock transfer fee rate only for SHSE

----[[
-- if broker rate is 0.015%, the criticalFeePoint should be 33333.34, Guolian
local BrokerRate = 0.00015	-- Exchange rate set by broker
local CriticalFeePoint = 33333.34
----]]

--[[
--if broker rate is 0.030%, the criticalFeePoint should be 16666.67, Merchants Securities
local BrokerRate = 0.0003	-- Exchange rate set by broker
local CriticalFeePoint = 16666.67
--]]

-- just for test
--local arg = {0, 53.0, 700, 'SHSE'}

--function CalcCostFee(BuyPrice, SellPrice, StockVol, Market)
function CalcCostFee(BuyPrice, SellPrice, StockVol, Market)
	--local BuyPrice,SellPrice,StockVol,Market = arg[2], arg[3], arg[4], arg[5]
	local TotalCostFee = 0
	local BuyCost = BuyPrice * StockVol
	local SellCost = SellPrice * StockVol
	if (BuyCost >= CriticalFeePoint) then
		TotalCostFee = BuyCost * BrokerRate
	else 	if (BuyCost > 0) then
				TotalCostFee = 5
			end
	end
	
	if (SellCost > 0 ) then
		if SellCost < CriticalFeePoint then
			TotalCostFee = TotalCostFee + 5 + SellCost * StamptaxRate
		else
			TotalCostFee = TotalCostFee + SellCost * (BrokerRate + StamptaxRate)
		end
	end
	
	if Market and Market == "SHSE" then
		--TotalCostFee = TotalCostFee + StockVol * TransferFeeRate
		TotalCostFee = TotalCostFee + (BuyCost+SellCost) * TransferFeeRate
	end
	
	return TotalCostFee
end

--[[
function GetCubeRoot(Num)
X^3 == a
X*(X^2-1) == a-X
(X-1)*(X+1) == a/X-1
X-1 == (a/X-1)/(X+1)
X == (a/X-1+X+1)/(X+1)
X0 == (a/X+X)/(X+1)
end
--]]

function GetSqr(Num)
	print(string.format("Num=%f ", Num))
	local x0,x1 = 0, Num/2
	local Count = 0;
	while true do
		Count = Count + 1
		--print(string.format("x1=%f ", x1))
		x0 = (Num+x1)/(x1+1)
		if (math.abs(x0-x1) < 0.000001) then
			break
		end
		print(string.format("x1=%f, x0=%f ", x1, x0))
		x1 = x0
	end
	print(string.format("Get square root of %f  is %f, cost round %d", Num, x0, Count))
end

--[[ the critical yield sell price formual as below:
	SP = f(cost) / Vol + BP
	(SP: Sell Price, Vol: Stock volumn; BP: Buy Price)
	
	f(cost) = BuyCost + SellCost + TransFerCost
	if (BuyCost > CriticalFeePoint)
	{
		f(cost) = BP * Vol * BrokerRate + SP * Vol(BrokerRate + StamptaxRate)
		if (Market == "SHSE")
			f(cost) = f(cost) + Vol * TransFerCost
	}
	else if (SellCost > CriticalFeePoint)
	{
		f(cost) = 5 + SP * Vol(BrokerRate + StamptaxRate)
		if (Market == "SHSE")
			f(cost) = f(cost) + Vol * TransFerCost
	}
	else if (SellCost < CriticalFeePoint)
	{
		f(cost) = 5 + 5 + SP * Vol * StamptaxRate
		if (Market = "SHSE")
			f(cost) = f(cost) + Vol * TransFerCost
	}
]]

-- Three kind of the profit price formular
--[[
	R1 == Broker Rate; R2 == StampRate; R3 == TranferRate(only SHSE)

	1.S1 >= {(B1+R3)/(1-R2) + 10/(V*(1-R2))} ==>(B1*V <CP && S1*V <CP);
	2.S1 >= {(B1+R3)/(1-R1-R2) + 5/(V*(1-R1-R2))} ==>(B1*V <CP && S1*V >CP);
	3.S1 >= {(B1*(1+R1)+R3)/(1-R1-R2)} ==>(B1*V >CP && S1*V >CP);
]]

function CalcProfitSellPrice(BuyPrice, StockVol, Market)
--function CalcProfitSellPrice()	
	--local BuyPrice, StockVol, Market = arg[2], arg[3], arg[4]
	local TotalCostFee = 5
	local SellPrice = nil
		
	local BuyRate = 5
	if (BuyPrice * StockVol > CriticalFeePoint) then
		-- sell amount larger than the CriticalFeePoint
		if (Market == "SHSE") then
			SellPrice = (BuyPrice*(1+BrokerRate)+ TransferFeeRate) / (1-BrokerRate-StamptaxRate)
		else
			SellPrice = BuyPrice*(1+BrokerRate) / (1-BrokerRate-StamptaxRate)
		end
		
		if (SellPrice * StockVol > CriticalFeePoint) then
			return SellPrice
		else
			return nil
		end
	else
		-- first assume that the sell amount is less than CriticalFeePoint
		if (Market == "SHSE") then
			SellPrice = (BuyPrice+TransferFeeRate)/(1-StamptaxRate) + 10/(StockVol*(1-StamptaxRate))
		else
			SellPrice = BuyPrice/(1-StamptaxRate) + 10/(StockVol*(1-StamptaxRate))
		end	

		if (SellPrice * StockVol < CriticalFeePoint) then
			return SellPrice
		end
		
		-- second assume that the sell amount is larger than CriticalFeePoint
		if (Market == "SHSE") then
			SellPrice = (BuyPrice +TransferFeeRate)/(1-BrokerRate-StamptaxRate) + 5/(StockVol*(1-BrokerRate-StamptaxRate))
		else
			SellPrice = BuyPrice / (1-BrokerRate-StamptaxRate) + 5/(StockVol*(1-BrokerRate-StamptaxRate))
		end	
		
		if (SellPrice * StockVol > CriticalFeePoint) then
			return SellPrice
		else
			return nil
		end
	end
	
	return SellPrice
end


-- Three kind of the new buy volume  formular
--[[
	R1 == Broker Rate; R2 == StampRate; R3 == TranferRate(only SHSE)

	1.BV = SV*(SP-SP*(R1+R2)-R3) /(BP*(1+R1)) (SV*SP > CP && BV*BP > CP)
	2.BV = {SV*(SP_SP*(R1+R2)-R3)-5} / BP     (SV*SP > CP && BV*BP < CP)
	3.BV = {SV*SP*(1-R2)-10} / BP			  (SV*SP < CP && BV*BP < CP)
]]

--function CalcProfitBuyVol(SellPrice, StockVol, Yield, Market)
function CalcProfitBuyVol(SellPrice, StockVol, Yield, Market)
	local SellPrice, StockVol, Yield, Market = arg[2], arg[4], arg[4], arg[5]
	local BuyPrice = SellPrice / (1 + (Yield or 0.1))
	local BuyVol = nil
	if SellPrice * StockVol > CriticalFeePoint then
		-- first assume that the buy amount is larger than CriticalFeePoint
		if (Market == "SHSE") then
			BuyVol = StockVol*(SellPrice*(1-BrokerRate-StamptaxRate)-TransferFeeRate) / (BuyPrice*(1+BrokerRate))
		else
			BuyVol = StockVol*SellPrice*(1-BrokerRate-StamptaxRate) / (BuyPrice*(1+BrokerRate))
		end
		
		if BuyVol * BuyPrice > CriticalFeePoint then
			return BuyVol
		end
				
		-- second assume that the buy amount is less than CriticalFeePoint
		if (Market == "SHSE") then
			BuyVol = (StockVol*(SellPrice*(1-BrokerRate-StamptaxRate)-TransferFeeRate) - 5) / BuyPrice
		else
			BuyVol = (StockVol*(SellPrice*(1-BrokerRate-StamptaxRate)) - 5) / BuyPrice
		end
		
		if BuyVol * BuyPrice < CriticalFeePoint then
			return BuyVol
		else
			return nil
		end
	else
		if (Market == "SHSE") then
			BuyVol = (StockVol*(SellPrice*(1-StamptaxRate)-TransferFeeRate) - 10) / BuyPrice
		else
			BuyVol = (StockVol*SellPrice*(1-BrokerRate) - 10) / BuyPrice
		end	
		
		if BuyVol * BuyPrice > CriticalFeePoint then
			BuyVol = nil
		end
	end

	return BuyVol
end

-- assume the buy amount is equal to sell amount 
-- Three kind of the new buy price formular
--[[
	R1 == Broker Rate; R2 == StampRate; R3 == TranferRate(only SHSE)

	1.BP = (SP-SP*(R1+R2)-R3) /(1+R1) 				(SV*SP > CP && BV*BP > CP)
	2.BP = (SV*(SP-SP*(R1+R2)-R3) - 5) / SV  		(SV*SP > CP && BV*BP < CP)
	3.BP = (SP*SV-SP*SV*R2-SV*R3-10) / SV		(SV*SP < CP && BV*BP < CP)
]]

function CalcProfitBuyPrice(SellPrice, StockVol, Market)
--function CalcProfitBuyPrice()
--	local SellPrice, StockVol, Market = arg[2], arg[3], arg[4]
	local BuyPrice = nil
	if (SellPrice * StockVol > CriticalFeePoint) then
		-- firstly, assume that buy amount is larger than CriticalFeePoint
		if (Market == "SHSE") then
			BuyPrice = (SellPrice*(1-BrokerRate-StamptaxRate)-TransferFeeRate) / (1+BrokerRate)
		else
			BuyPrice = (SellPrice*(1-BrokerRate-StamptaxRate)) / (1+BrokerRate)
		end	
		
		if BuyPrice * StockVol > CriticalFeePoint then
			return BuyPrice
		end
		
		-- secondly, assume that buy amount is less that CriticalFeePoint
		if (Market == "SHSE") then
			BuyPrice = (StockVol*(SellPrice*(1-BrokerRate-StamptaxRate)-TransferFeeRate) - 5) / StockVol
		else
			BuyPrice = (StockVol*SellPrice*(1-BrokerRate-StamptaxRate) - 5) / StockVol
		end
		
		if BuyPrice * StockVol < CriticalFeePoint then
			return BuyPrice
		else
			return nil
		end
	else
		if (Market == "SHSE") then
			BuyPrice = (StockVol*(SellPrice*(1-StamptaxRate)-TransferFeeRate) - 10) / StockVol
		else
			BuyPrice = (StockVol*SellPrice*(1-StamptaxRate) - 10) / StockVol
		end
		
		if BuyPrice * StockVol > CriticalFeePoint then
			return nil
		end
	end

	return BuyPrice
end

-- Calcution the profit yield according by first sell and later buy it with lesser price
-- while the buy qty is not changed
--function CalcProfitWithQty(SellPrice, Qty, Market)
function CalcProfitWithQty()
	local SellPrice, Qty, Market = arg[2], arg[3], arg[4]
	local ProfitBuyPrice = CalcProfitBuyPrice(SellPrice, Qty, Market)
	if ProfitBuyPrice then
		local ActBuyPrice = ProfitBuyPrice * 1000
		local LastDecim = ActBuyPrice % 10
		if LastDecim > 0 then
			ActBuyPrice = (ActBuyPrice - LastDecim) / 1000
		end
		
		local Fee = ((SellPrice*Qty > CriticalFeePoint) and (SellPrice*Qty*(BrokerRate+StamptaxRate))) or (SellPrice*Qty*StamptaxRate+5)
		Fee = Fee + ((ActBuyPrice*Qty > CriticalFeePoint) and (ActBuyPrice*Qty*BrokerRate)) or 5
		local ActProfit = SellPrice*Qty - ActBuyPrice*Qty
		if (Market == "SHSE") then
			Fee = Fee + Qty * TransferFeeRate
		end
		
		ActProfit = ActProfit - Fee
		print(string.format("Sell Price:%.3f, \r\nProfit Buy Price:%.3f, \r\nActually Buy Price:%.3f, \r\n Qty:%d, \r\nActuall Profit:%f, \r\nTotal Fee:%f, \r\n",
			SellPrice, ProfitBuyPrice, ActBuyPrice, Qty, ActProfit, Fee))
	end
end

-- Calcution the profit yield according by first sell and later buy it with lesser price 
-- that buy qty should larger than the sell one
--function CalcProfitByYield(SellPrice, Qty, Yield, Market)
function CalcProfitByYield()
	local SellPrice, Qty, Yield, Market = arg[2], arg[3], arg[4], arg[5]
	local ProfitBuyVol = CalcProfitBuyVol(SellPrice, Qty, Yield, Market)
	local ProfitPrice = SellPrice/(1+Yield)
	if ProfitBuyVol then
		print(string.format("SellPrice: %.3f, \r\nQty:%d, \r\nYield:%%%f, \r\nProfitBuyPrice: %.3f, \r\nProfitBuyVol:%f, \r\nSell Amount:%f, \r\n", 		
		SellPrice, Qty, Yield*100, ProfitPrice, ProfitBuyVol, SellPrice*Qty))
		
		local ActBuyPrice = ProfitPrice * 1000
		local LastDecim = ActBuyPrice % 10
		if LastDecim > 0 then
			ActBuyPrice = (ActBuyPrice - LastDecim) / 1000
		end
		
		local oddQty = ProfitBuyVol % 100
		local ActQty = ProfitBuyVol - oddQty
		local ActProfit = SellPrice*Qty - ActBuyPrice*ActQty
		local ExterBenefit = (ActQty - Qty) * ActBuyPrice
		local Fee = ((SellPrice*Qty > CriticalFeePoint) and (SellPrice*Qty*(BrokerRate+StamptaxRate))) or (SellPrice*Qty*StamptaxRate+5)
		Fee = Fee + ((ActBuyPrice*ActQty > CriticalFeePoint) and (ActBuyPrice*ActQty*BrokerRate)) or 5
		if (Market == "SHSE") then
			Fee = Fee + Qty * TransferFeeRate
		end
		
		ActProfit = ActProfit - Fee
		print(string.format("Actually Buy Price:%.3f, \r\n Actuall Buy Qty:%d, \r\nActuall Profit:%f, \r\nExteral Benefit:%f, \r\nTotalFee:%f\r\n",
			ActBuyPrice, ActQty, ActProfit, ExterBenefit, Fee))
	end
end

-- Calculate the profit that first buy and then sell in larger price in a tiny trade cycle
--function CalcWaveProfit(BuyPrice, Qty, Yield, Market)
function CalcWaveProfit()
	local BuyPrice, Qty, Yield, Market = arg[2], arg[3], arg[4], arg[5]
	local ProfitPrice = BuyPrice * (1+Yield)
	--ProfitPrice = tonumber(string.format("%.3f",ProfitPrice))
	ProfitPrice = string.format("%.3f",ProfitPrice)
	local LastDecim = (ProfitPrice * 1000) % 10
	local ActSellPrice = ProfitPrice
	if LastDecim > 0 then
		ActSellPrice = (ProfitPrice * 1000 - LastDecim + 10) / 1000
	end
	
	local Fee = CalcCostFee(BuyPrice, ActSellPrice, Qty, Market)
	local Profit = (ActSellPrice - BuyPrice)*Qty - Fee
	
	print("CalcWaveProfit\r\n")
	print(string.format("Total Amount:%f, \r\nBuy Price:%.3f, \r\nQty:%d, \r\nSell Price:%f, \r\nYield:%%%f, \r\nProfit:%f, \r\nTotalFee:%f\r\n",
			BuyPrice*Qty, BuyPrice, Qty, ActSellPrice, 100*Yield, Profit, Fee))
end


-- Calculate the Sell & Buy profit to reduce the loss of wealthy
-- Calculate the properly price of Sell & Buy, which a stop loss wealth method for security trading
--function CalcSellBuyPrice(SellPrice, Qty, Market)
function CalcSellBuyPrice()
	local SellPrice, Qty, Market = arg[2], arg[3], arg[4]
	local SellFee = CalcCostFee(0, SellPrice, Qty, Market)
	local NetAmt = SellPrice*Qty - SellFee
	local BuyPrice = NetAmt / Qty
	local BuyFee = CalcCostFee(BuyPrice, 0, Qty, Market)
	BuyPrice = (NetAmt-BuyFee)/Qty
	local Fee = SellFee + BuyFee	
	print(string.format("the properly buy price value is %f, when sell price:%f, qty:%d, fee:%f\r\n", BuyPrice, SellPrice, Qty, Fee))	
end

-- Calculate the profit of Sell & Buy, which a stop loss wealth method for security trading
--function CalcSellBuyProfit(SellPrice, BuyPrice, SellQty, Market)
function CalcSellBuyProfit()
	local SellPrice, BuyPrice, SellQty, Market = arg[2], arg[3], arg[4], arg[5]
	local SellFee = CalcCostFee(0, SellPrice, SellQty, Market)
	local NetAmt = SellPrice*SellQty - SellFee
	local BuyQty = NetAmt/BuyPrice
	local BuyFee = CalcCostFee(BuyPrice, 0, BuyQty, Market)
	local StopLossProfit = NetAmt-BuyFee-BuyPrice*SellQty
	local totalFee = SellFee+BuyFee
	local Volatility = (SellPrice / BuyPrice)*100 - 100
	print(string.format("the profit of sell&buy is %f, volatility is %.3f%%, when sell price:%f, qty:%d, buy price:%f, buy qty:%f, fee:%f\r\n", StopLossProfit, Volatility, SellPrice, SellQty, BuyPrice, BuyQty, totalFee))
end

-- Calculate the net profit 
--function CalcNetProfit(BPrc, BQty, SPrc, SQty, Market)
function CalcNetProfit()
	local BPrc, BQty, SPrc, SQty, Market = arg[2], arg[3], arg[4], arg[5], arg[6]
	local BFee = CalcCostFee(BPrc, 0, BQty, Market)	
	local SFee = CalcCostFee(0, SPrc, SQty, Market)
	local NetProfit = SPrc * SQty - BPrc * BQty - BFee - SFee
	local ProfitRate = 100* NetProfit / (BPrc*BQty)
	print(string.format("BFee is %f, SFee is %f", BFee, SFee))
	local TotalFee = BFee + SFee
	print(string.format("the net proft is %f, rate is %f%%, total Fee is %f, while sell price:%f, sell qty:%d, buy Price:%f, buy qty:%d\n",
		NetProfit, ProfitRate, TotalFee, SPrc, SQty, BPrc, BQty))
end

--Calculate the StopLossSellPrc
function CalcStopLossSellPrc()
	local BuyPrice, StockVol, Market = arg[2], arg[3], arg[4]
	local SellPrc = CalcProfitSellPrice(BuyPrice, StockVol, Market)
	print(string.format("BuyPrice: %.3f, \r\nQty:%d, \r\nStopLoss Sell price: %.3f, \r\nMarket:%s\r\n", BuyPrice, StockVol, SellPrc, Market))
end
--[[
	A pseudo main function which looks like the C/C++ entry function
--]]
function main(arg)
	local CalcFee = nil
	if CalcFee then
		local BuyCost = arg[1] * arg[3]
		local SellAsset = arg[2] * arg[3]

		--local Profit = CalcProfit(6.23, 6.34, 8000)
		local Fee = CalcCostFee(arg[1], arg[2], arg[3], arg[4])
		local Profit = SellAsset - BuyCost - Fee

		--CalcCostFee(arg[1], arg[2], arg[3], arg[4])
		--CalcProfit(arg[1], arg[2], arg[3], arg[4])
		local Volatility = 100*(arg[2] - arg[1])/arg[1]

		print(string.format("Buy Cost: %.3f,\r\nSell asset: %.3f,\r\nfee: %.3f,\r\ntotal profit: %.3f\r\nVolatility: %.3f%%",
			BuyCost, SellAsset, Fee, Profit, Volatility))
	end
	
	local Market = arg[3] or "SHSE"
	local ProfitPrice = nil
	if ProfitPrice then
		ProfitPrice = CalcProfitSellPrice(arg[1],arg[2],Market)
		print(string.format("BuyPrice: %.3f, \r\nQty:%d, \r\nProfitPrice: %.3f \r\n", arg[1], arg[2], ProfitPrice))
	end
	
	local ProfitBuyVol = CalcProfitBuyVol(arg[1], arg[2], arg[3], Market)
	local ProfitPrice = arg[1] /(1+arg[3])
	if ProfitBuyVol then
		print(string.format("SellPrice: %.3f, \r\nQty:%d, \r\nYield:%.f, \r\nProfitBuyPrice: %.3f, \r\nProfitBuyVol:%.f, \r\n", 		
		arg[1], arg[2], arg[3], ProfitPrice, ProfitBuyVol))
	end
	
end

local switch = {
	CalcFee = CalcCostFee,
	CalcSellPrcProfit = CalcStopLossSellPrc,
	CalcBuyVolProfit = CalcProfitBuyVol,
	CalcBuyPrcProfit = CalcProfitBuyPrice,
	CalcProfitQty = CalcProfitWithQty,
	ClacYieldProfit = CalcProfitByYield,
	CalcWaveProfit = CalcWaveProfit,
	CalcStopLossBidPrc = CalcSellBuyPrice,
	CalcStopLossProfit = CalcSellBuyProfit,
	CalcNetProfit = CalcNetProfit,
	}


local func = switch[arg[1]]
if (func ~= nil) then
	func(arg)
else
   print(string.format('function :%s not found in the list according by key:%s \r\n', func, arg[1]))
end

--GetSqr(arg[1])
--main(arg)
--local arg = {9.07, 6000, 0.0513, "SZSE"}
--[[
CalcProfitWithQty(arg[1], arg[2], arg[3])

CalcProfitByYield(arg[1], arg[2], arg[3], arg[4])

--argument:BuyPrice, Qty, Yield, Market
CalcWaveProfit(arg[1], arg[2], arg[3], arg[4])

--argument:SellPrice, Qty, Market
--local arg = { 16.82, 7100, "SHSE"}
CalcSellBuyPrice(arg[1],arg[2],arg[3])

--local arg = {16.82, 16.7, 7100, "SHSE"}
CalcSellBuyProfit(arg[1],arg[2],arg[3],arg[4])

--local arg = {BPrc, BQty, SPrc, SQty, Market}
CalcNetProfit(arg[1], arg[2], arg[3], arg[4], arg[5])

--]]

--[[
-- for test case

local Market = "SHSE"

local ProfitBuyPrice = CalcProfitBuyPrice(3.47, 11100,Market)
if ProfitBuyPrice then
	print(string.format("SellPrice: %.3f, \r\nQty:%d, \r\nProfitBuyPrice: %.3f \r\n", 3.47, 11100, ProfitBuyPrice))
end


local ProfitBuyVol = CalcProfitBuyVol(3.47, 11100, 0.0125, Market)
local ProfitPrice = 3.47 /(1+0.0125)
if ProfitBuyVol then
	print(string.format("SellPrice: %.3f, \r\nQty:%d, \r\nYield:%.f, \r\nProfitBuyPrice: %.3f, \r\nProfitBuyVol:%.f, \r\n", 
	3.47, 11100, 0.0125, ProfitPrice, ProfitBuyVol))
end

--]]
