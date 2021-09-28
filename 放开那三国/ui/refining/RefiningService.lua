-- Filename: RefiningService.lua
-- Author: zhang zihang
-- Date: 2015-4-23
-- Purpose: 炼化炉网络层

module ("RefiningService", package.seeall)

--==================== Resolve ====================
--[[
	@des 	:炼化武将
	@param  :已经选择的英雄
	@param  :回调
--]]
function resolveHero(p_selectedHero,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.resolveHero" then
		    p_callBack(p_selectedHero,dictData)
		end	
    end

    local arg = CCArray:create()
    local subArg = CCArray:create()
	for i = 1,#p_selectedHero do
		subArg:addObject(CCInteger:create(tonumber(p_selectedHero[i].hid)))
	end
	arg:addObject(subArg)

    Network.rpc(serviceCallBack,"mysteryshop.resolveHero","mysteryshop.resolveHero",arg,true)
end

--[[
	@des 	:炼化装备
	@param  :已经选择的装备
	@param  :回调
--]]
function resolveItem(p_selectedItem,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.resolveItem" then
		    p_callBack(dictData)
		end	
    end

    local arg = CCArray:create()
    local subArg = CCArray:create()
	for i = 1,#p_selectedItem do
		subArg:addObject(CCInteger:create(tonumber(p_selectedItem[i].item_id)))
	end
	arg:addObject(subArg)

    Network.rpc(serviceCallBack,"mysteryshop.resolveItem","mysteryshop.resolveItem",arg,true)
end

--[[
	@des 	:炼化宝物
	@param  :已经选择的宝物
	@param  :回调
--]]
function resolveTreas(p_selectedTreas,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.resolveTreasure" then
		    p_callBack(dictData)
		end	
    end

    local arg = CCArray:create()
    local subArg = CCArray:create()
	for i = 1,#p_selectedTreas do
		subArg:addObject(CCInteger:create(tonumber(p_selectedTreas[i].item_id)))
	end
	arg:addObject(subArg)

    Network.rpc(serviceCallBack,"mysteryshop.resolveTreasure","mysteryshop.resolveTreasure",arg,true)
end

--[[
	@des 	:炼化时装
	@param  :已经选择的时装
	@param  :回调
--]]
function resolveCloth(p_selectedCloth,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.resolveDress" then
		    p_callBack(dictData)
		end	
    end

    local arg = CCArray:create()
    local subArg = CCArray:create()
	for i = 1,#p_selectedCloth do
		subArg:addObject(CCInteger:create(tonumber(p_selectedCloth[i].item_id)))
	end
	arg:addObject(subArg)

    Network.rpc(serviceCallBack,"mysteryshop.resolveDress","mysteryshop.resolveDress",arg,true)
end

--[[
	@des 	:炼化神兵
	@param  :已经选择的神兵
	@param  :回调
--]]
function resolveGod(p_selectedGod,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "godweapon.resolve" then
		    p_callBack(dictData)
		end	
    end

    local arg = CCArray:create()
    local subArg = CCArray:create()
	for i = 1,#p_selectedGod do
		subArg:addObject(CCInteger:create(tonumber(p_selectedGod[i].item_id)))
	end
    local treaArg = CCArray:create() --创建出来备用
	arg:addObject(subArg)

    Network.rpc(serviceCallBack,"godweapon.resolve","godweapon.resolve",arg,true)
end
--[[
    @des    :炼化符印
    @param  :已经选择的符印
    @param  :回调
--]]
function resolveToken (p_selectedToken,p_callBack)
    local serviceCallBack = function(cbFlag,dictData,bRet)
        if not bRet then
            return
        end
        if cbFlag == "mysteryshop.resolveRune" then
            p_callBack(dictData)
        end 
    end
    print("p_selectedToken")
    print_t(p_selectedToken)
    local arg = CCArray:create()
    local subArg = CCArray:create()
    for i = 1,#p_selectedToken do
        subArg:addObject(CCInteger:create(tonumber(p_selectedToken[i].item_id)))
    end
    arg:addObject(subArg)

    Network.rpc(serviceCallBack,"mysteryshop.resolveRune","mysteryshop.resolveRune",arg,true)
end
--==================== Reborn ====================
--[[
	@des 	:重生普通武将
	@param  :已经选择的武将
	@param  :回调
--]]
function rebornHero(p_selectedId,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.rebornHero" then
		    p_callBack(dictData)
		end	
    end

    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(p_selectedId.hid)))

    Network.rpc(serviceCallBack,"mysteryshop.rebornHero","mysteryshop.rebornHero",subArg,true)
end

--[[
	@des 	:重生橙色武将
	@param  :已经选择的武将
	@param  :回调
--]]
function rebornOrangeHero(p_selectedId,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.rebornOrangeHero" then
		    p_callBack(dictData)
		end	
    end

    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(p_selectedId.hid)))

    Network.rpc(serviceCallBack,"mysteryshop.rebornOrangeHero","mysteryshop.rebornOrangeHero",subArg,true)
end
--[[
    @des    :重生红色武将
    @param  :已经选择的武将
    @param  :回调
--]]
function rebornRedHero(p_selectedId,p_callBack)
    local serviceCallBack = function(cbFlag,dictData,bRet)
        if not bRet then
            return
        end
        if cbFlag == "mysteryshop.rebornRedHero" then
            p_callBack(dictData)
        end 
    end

    local subArg = CCArray:create()
    subArg:addObject(CCInteger:create(tonumber(p_selectedId.hid)))

    Network.rpc(serviceCallBack,"mysteryshop.rebornRedHero","mysteryshop.rebornRedHero",subArg,true)
end
--[[
	@des 	:重生装备
	@param  :已经选择的装备
	@param  :回调
--]]
function rebornItem(p_selectedId,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.rebornItem" then
		    p_callBack(dictData)
		end	
    end

    local args = CCArray:create()
    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(p_selectedId.item_id)))
	args:addObject(subArg)

    Network.rpc(serviceCallBack,"mysteryshop.rebornItem","mysteryshop.rebornItem",args,true)
end

--[[
	@des 	:重生宝物
	@param  :已经选择的宝物
	@param  :回调
--]]
function rebornTreas(p_selectedId,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.rebornTreasure" then
		    p_callBack(dictData)
		end	
    end

    local args = CCArray:create()
    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(p_selectedId.item_id)))
	args:addObject(subArg)

    Network.rpc(serviceCallBack,"mysteryshop.rebornTreasure","mysteryshop.rebornTreasure",args,true)
end

--[[
	@des 	:重生时装
	@param  :已经选择的时装
	@param  :回调
--]]
function rebornCloth(p_selectedId,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.rebornDress" then
		    p_callBack(dictData)
		end	
    end

    local args = CCArray:create()
    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(p_selectedId.item_id)))
	args:addObject(subArg)

    Network.rpc(serviceCallBack,"mysteryshop.rebornDress","mysteryshop.rebornDress",args,true)
end

--[[
	@des 	:重生神兵
	@param  :已经选择的神兵
	@param  :回调
--]]
function rebornGod(p_selectedId,p_callBack)
	local serviceCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "godweapon.reborn" then
		    p_callBack(dictData)
		end	
    end

    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(p_selectedId.item_id)))

    Network.rpc(serviceCallBack,"godweapon.reborn","godweapon.reborn",subArg,true)
end
--[[
    @des    :重生锦囊
    @param  :已经选择的锦囊
    @param  :回调
--]]
function rebornPocket(p_selectedId,p_callBack)
    local serviceCallBack = function(cbFlag,dictData,bRet)
        if not bRet then
            return
        end
        if cbFlag == "mysteryshop.rebornPocket" then
            p_callBack(dictData)
        end 
    end

    -- local subArg = CCArray:create()
    -- subArg:addObject(CCInteger:create(tonumber(p_selectedId.item_id)))
    local args = CCArray:create()
    local subArg = CCArray:create()
    subArg:addObject(CCInteger:create(tonumber(p_selectedId.item_id)))
    args:addObject(subArg)

    Network.rpc(serviceCallBack,"mysteryshop.rebornPocket","mysteryshop.rebornPocket",args,true)
end
--==================== Soul ====================
--[[
    @des    :武将化魂
    @param  :选择的武将hid的数组
    @param  :回调
--]]
function soulHero(p_selectedHero,p_callBack)
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(p_callBack ~= nil) then
				p_callBack(cbFlag, dictData.ret, bRet)
			end
		end
	end
	local args = Network.argsHandlerOfTable({p_selectedHero})
	Network.rpc(requestFunc, "mysteryshop.resolveHero2Soul", "mysteryshop.resolveHero2Soul", args, true)
end
--[[
    @des    :武将精华化魂
    @param  :选择的武将hid的数组
    @param  :回调
--]]
function resolveHeroJH( p_selectedAry,p_callBack )
	local requestFunc = function( cbFlag, dictData, bRet )
		if(bRet == true) then
			if(p_callBack ~= nil) then
				p_callBack(cbFlag, dictData.ret, bRet)
			end
		end
	end
	local dic = CCDictionary:create()
	for i,v in ipairs(p_selectedAry) do
		dic:setObject(CCInteger:create(v.selectNum),v.item_id)
	end
	local args = Network.argsHandlerOfTable({dic})
	Network.rpc(requestFunc, "mysteryshop.resolveHeroJH", "mysteryshop.resolveHeroJH", args, true)
end

--==================== 兵符 ====================
--[[
    @des    :炼化兵符
    @param  :arrItemId
    @param  :
--]]
function resolveTally( arrItemId,p_callBack )
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callBack ~= nil) then
				p_callBack(dictData.ret)
			end
		end
	end
    local subArg = CCArray:create()
    for i,item in ipairs(arrItemId) do
        subArg:addObject(CCInteger:create(tonumber(item.item_id)))
    end
	local args = Network.argsHandlerOfTable({subArg})
	Network.rpc(requestFunc, "mysteryshop.resolveTally", "mysteryshop.resolveTally", args, true)
end
--[[
    @des    :重生
    @param  :arrItemId
    @param  :
--]]
function rebornTally( arrItemId,p_callBack )
	local requestFunc = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(p_callBack ~= nil) then
				p_callBack(dictData.ret)
			end
		end
	end
	local subArg = CCArray:create()
    for i,item in ipairs(arrItemId) do
        subArg:addObject(CCInteger:create(tonumber(item.item_id)))
    end
	local args = Network.argsHandlerOfTable({subArg})
	-- local args = Network.argsHandlerOfTable({arrItemId})
	Network.rpc(requestFunc, "mysteryshop.rebornTally", "mysteryshop.rebornTally", args, true)
end

-------------------------------- 战车 ------------------------------

--[[
	@desc   : 炼化战车
    @param  : pArrItemId 炼化的战车数组 pCallBack 回调
    @return :
--]]
function resolveChariot( pArrItemId, pCallBack )
	local requestFunc = function(cbFlag , dictData, bRet)
		if(dictData.err == "ok") then
			if(pCallBack ~= nil) then
				pCallBack(dictData.ret)
			end
		end
	end
	local subArg = CCArray:create()
    for i,item in ipairs(pArrItemId) do
        subArg:addObject(CCInteger:create(tonumber(item.item_id)))
    end
	local args = Network.argsHandlerOfTable({subArg})
	Network.rpc(requestFunc, "chariot.resolve", "chariot.resolve", args, true)
end

--[[
	@desc   : 重生战车
    @param  : pArrItemId 重生的战车数组 pCallBack 回调
    @return :
--]]
function rebornChariot( pArrItemId, pCallBack )
	local requestFunc = function(cbFlag , dictData, bRet)
		if(dictData.err == "ok") then
			if(pCallBack ~= nil) then
				pCallBack(dictData.ret)
			end
		end
	end
	local itemId = tonumber(pArrItemId[1].item_id)
	local args = Network.argsHandlerOfTable({itemId})
	Network.rpc(requestFunc, "chariot.reborn", "chariot.reborn", args, true)
end



