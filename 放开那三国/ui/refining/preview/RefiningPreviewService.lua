-- Filename: RefiningPreviewService.lua
-- Author: lgx
-- Date: 2016-05-11
-- Purpose: 炼化/重生预览网络接口层

module("RefiningPreviewService", package.seeall)

-------------------------------------------炼化预览接口-----------------------------------------------

--[[
    @desc   : 炼化武将预览
    @param  : pSelectedHero 已经选择的英雄 pCallBack 回调
    @return :
--]]
function previewResolveHero( pSelectedHero, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.previewResolveHero" then
			if (pCallBack ~= nil) then
		    	pCallBack(pSelectedHero,dictData.ret)
			end
		end	
    end

    local arg = CCArray:create()
    local subArg = CCArray:create()
	for i = 1,#pSelectedHero do
		subArg:addObject(CCInteger:create(tonumber(pSelectedHero[i].hid)))
	end
	arg:addObject(subArg)

    Network.rpc(requestCallBack,"mysteryshop.previewResolveHero","mysteryshop.previewResolveHero",arg,true)
end

--[[
    @desc   : 炼化装备预览
    @param  : pSelectedItem 已经选择的装备 pCallBack 回调
    @return :
--]]
function previewResolveItem( pSelectedItem, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.previewResolveItem" then
			if (pCallBack ~= nil) then
		    	pCallBack(pSelectedItem,dictData.ret)
		    end
		end	
    end

    local arg = CCArray:create()
    local subArg = CCArray:create()
	for i = 1,#pSelectedItem do
		subArg:addObject(CCInteger:create(tonumber(pSelectedItem[i].item_id)))
	end
	arg:addObject(subArg)

    Network.rpc(requestCallBack,"mysteryshop.previewResolveItem","mysteryshop.previewResolveItem",arg,true)
end

--[[
    @desc   : 炼化宝物预览
    @param  : pSelectedTreas 已经选择的宝物 pCallBack 回调
    @return :
--]]
function previewResolveTreasure( pSelectedTreas, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.previewResolveTreasure" then
			if (pCallBack ~= nil) then
		    	pCallBack(pSelectedTreas,dictData.ret)
		    end
		end	
    end

    local arg = CCArray:create()
    local subArg = CCArray:create()
	for i = 1,#pSelectedTreas do
		subArg:addObject(CCInteger:create(tonumber(pSelectedTreas[i].item_id)))
	end
	arg:addObject(subArg)

    Network.rpc(requestCallBack,"mysteryshop.previewResolveTreasure","mysteryshop.previewResolveTreasure",arg,true)
end

--[[
    @desc   : 炼化时装预览
    @param  : pSelectedDress 已经选择的时装 pCallBack 回调
    @return :
--]]
function previewResolveDress( pSelectedDress, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.previewResolveDress" then
			if (pCallBack ~= nil) then
		    	pCallBack(pSelectedDress,dictData.ret)
		    end
		end	
    end

    local arg = CCArray:create()
    local subArg = CCArray:create()
	for i = 1,#pSelectedDress do
		subArg:addObject(CCInteger:create(tonumber(pSelectedDress[i].item_id)))
	end
	arg:addObject(subArg)

    Network.rpc(requestCallBack,"mysteryshop.previewResolveDress","mysteryshop.previewResolveDress",arg,true)
end

--[[
    @desc   : 炼化神兵预览
    @param  : pSelectedGod 已经选择的神兵 pCallBack 回调
    @return :
--]]
function previewResolveGod( pSelectedGod, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "godweapon.previewResolve" then
			if (pCallBack ~= nil) then
		    	pCallBack(pSelectedGod,dictData.ret)
		    end
		end	
    end

    local arg = CCArray:create()
    local subArg = CCArray:create()
	for i = 1,#pSelectedGod do
		subArg:addObject(CCInteger:create(tonumber(pSelectedGod[i].item_id)))
	end
    local treaArg = CCArray:create() --创建出来备用
	arg:addObject(subArg)

    Network.rpc(requestCallBack,"godweapon.previewResolve","godweapon.previewResolve",arg,true)
end

--[[
    @desc   : 炼化符印预览
    @param  : pSelectedRune 已经选择的符印 pCallBack 回调
    @return :
--]]
function previewResolveRune( pSelectedRune, pCallBack )
    local requestCallBack = function(cbFlag,dictData,bRet)
        if not bRet then
            return
        end
        if cbFlag == "mysteryshop.previewResolveRune" then
        	if (pCallBack ~= nil) then
            	pCallBack(pSelectedRune,dictData.ret)
            end
        end 
    end

    local arg = CCArray:create()
    local subArg = CCArray:create()
    for i = 1,#pSelectedRune do
        subArg:addObject(CCInteger:create(tonumber(pSelectedRune[i].item_id)))
    end
    arg:addObject(subArg)

    Network.rpc(requestCallBack,"mysteryshop.previewResolveRune","mysteryshop.previewResolveRune",arg,true)
end

--[[
    @desc   : 炼化兵符预览
    @param  : pArrItemId 炼化的兵符数组 pCallBack 回调
    @return :
--]]
function previewResolveTally( pArrItemId, pCallBack )
	local requestCallBack = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(pCallBack ~= nil) then
				pCallBack(pArrItemId,dictData.ret)
			end
		end
	end
	local subArg = CCArray:create()
    for i,item in ipairs(pArrItemId) do
        subArg:addObject(CCInteger:create(tonumber(item.item_id)))
    end
	local args = Network.argsHandlerOfTable({subArg})
	Network.rpc(requestCallBack, "mysteryshop.previewResolveTally", "mysteryshop.previewResolveTally", args, true)
end

--[[
	@desc 	: 炼化战车预览
	@param 	: pArrItemId 炼化的战车数组 pCallBack 回调
	@return :
--]]
function previewResolveChariot( pArrItemId, pCallBack )
	local requestCallBack = function( cbFlag, dictData, bRet )
		if(dictData.err == "ok") then
			if(pCallBack ~= nil) then
				pCallBack(pArrItemId,dictData.ret)
			end
		end
	end
	local subArg = CCArray:create()
    for i,item in ipairs(pArrItemId) do
        subArg:addObject(CCInteger:create(tonumber(item.item_id)))
    end
	local args = Network.argsHandlerOfTable({subArg})
	Network.rpc(requestCallBack, "chariot.previewResolve", "chariot.previewResolve", args, true)
end

-------------------------------------------炼化预览接口-----------------------------------------------

-------------------------------------------重生预览接口-----------------------------------------------

--[[
	@desc 	: 重生普通武将预览
	@param  : pSelectedId 已经选择的武将
	@return : 
--]]
function previewRebornHero( pSelectedId, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.previewRebornHero" then
			if(pCallBack ~= nil) then
		    	pCallBack(pSelectedId,dictData.ret)
		    end
		end	
    end

    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(pSelectedId.hid)))

    Network.rpc(requestCallBack,"mysteryshop.previewRebornHero","mysteryshop.previewRebornHero",subArg,true)
end

--[[
	@desc 	: 重生橙色武将预览
	@param  : pSelectedId 已经选择的武将 pCallBack 回调
	@return : 
--]]
function previewRebornOrangeHero( pSelectedId, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.previewRebornOrangeHero" then
			if(pCallBack ~= nil) then
		    	pCallBack(pSelectedId,dictData.ret)
		    end
		end	
    end

    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(pSelectedId.hid)))

    Network.rpc(requestCallBack,"mysteryshop.previewRebornOrangeHero","mysteryshop.previewRebornOrangeHero",subArg,true)
end

--[[
	@desc 	: 重生红色武将预览
	@param  : pSelectedId 已经选择的武将 pCallBack 回调
	@return : 
--]]
function previewRebornRedHero( pSelectedId, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.previewRebornRedHero" then
			if(pCallBack ~= nil) then
		    	pCallBack(pSelectedId,dictData.ret)
		    end
		end	
    end

    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(pSelectedId.hid)))

    Network.rpc(requestCallBack,"mysteryshop.previewRebornRedHero","mysteryshop.previewRebornRedHero",subArg,true)
end

--[[
	@desc 	: 重生装备预览
	@param  : pSelectedId 已经选择的装备 pCallBack 回调
	@return : 
--]]
function previewRebornItem( pSelectedId, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.previewRebornItem" then
			if(pCallBack ~= nil) then
		    	pCallBack(pSelectedId,dictData.ret)
		    end
		end	
    end

    local args = CCArray:create()
    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(pSelectedId.item_id)))
	args:addObject(subArg)

    Network.rpc(requestCallBack,"mysteryshop.previewRebornItem","mysteryshop.previewRebornItem",args,true)
end

--[[
	@desc 	: 重生宝物预览
	@param  : pSelectedId 已经选择的宝物 pCallBack 回调
	@return : 
--]]
function previewRebornTreasure( pSelectedId, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.previewRebornTreasure" then
			if(pCallBack ~= nil) then
		    	pCallBack(pSelectedId,dictData.ret)
		    end
		end	
    end

    local args = CCArray:create()
    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(pSelectedId.item_id)))
	args:addObject(subArg)

    Network.rpc(requestCallBack,"mysteryshop.previewRebornTreasure","mysteryshop.previewRebornTreasure",args,true)
end

--[[
	@desc 	: 重生时装预览
	@param  : pSelectedId 已经选择的时装 pCallBack 回调
	@return : 
--]]
function previewRebornDress( pSelectedId, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "mysteryshop.previewRebornDress" then
			if(pCallBack ~= nil) then
		    	pCallBack(pSelectedId,dictData.ret)
		    end
		end	
    end

    local args = CCArray:create()
    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(pSelectedId.item_id)))
	args:addObject(subArg)

    Network.rpc(requestCallBack,"mysteryshop.previewRebornDress","mysteryshop.previewRebornDress",args,true)
end

--[[
    @desc   : 重生神兵预览
    @param  : pSelectedId 已经选择的神兵 pCallBack 回调
    @return :
--]]
function previewRebornGod( pSelectedId, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if not bRet then
			return
		end
		if cbFlag == "godweapon.previewReborn" then
			if(pCallBack ~= nil) then
		    	pCallBack(pSelectedId,dictData.ret)
		    end
		end	
    end

    local subArg = CCArray:create()
	subArg:addObject(CCInteger:create(tonumber(pSelectedId.item_id)))

    Network.rpc(requestCallBack,"godweapon.previewReborn","godweapon.previewReborn",subArg,true)
end

--[[
    @desc   : 重生锦囊预览
    @param  : pSelectedId 已经选择的锦囊 pCallBack 回调
    @return :
--]]
function previewRebornPocket( pSelectedId, pCallBack )
    local requestCallBack = function(cbFlag,dictData,bRet)
        if not bRet then
            return
        end
        if cbFlag == "mysteryshop.previewRebornPocket" then
        	if(pCallBack ~= nil) then
            	pCallBack(pSelectedId,dictData.ret)
            end
        end 
    end

    local args = CCArray:create()
    local subArg = CCArray:create()
    subArg:addObject(CCInteger:create(tonumber(pSelectedId.item_id)))
    args:addObject(subArg)

    Network.rpc(requestCallBack,"mysteryshop.previewRebornPocket","mysteryshop.previewRebornPocket",args,true)
end

--[[
    @desc   : 重生兵符预览
    @param  : pArrItemId 重生的兵符数组 pCallBack 回调
    @return :
--]]
function previewRebornTally( pArrItemId, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if(dictData.err == "ok") then
			if(pCallBack ~= nil) then
				pCallBack(pArrItemId[1],dictData.ret)
			end
		end
	end
	local subArg = CCArray:create()
    for i,item in ipairs(pArrItemId) do
        subArg:addObject(CCInteger:create(tonumber(item.item_id)))
    end
	local args = Network.argsHandlerOfTable({subArg})
	Network.rpc(requestCallBack, "mysteryshop.previewRebornTally", "mysteryshop.previewRebornTally", args, true)
end

--[[
    @desc   : 重生战车预览
    @param  : pArrItemId 重生的战车数组 pCallBack 回调
    @return :
--]]
function previewRebornChariot( pArrItemId, pCallBack )
	local requestCallBack = function(cbFlag,dictData,bRet)
		if(dictData.err == "ok") then
			if(pCallBack ~= nil) then
				pCallBack(pArrItemId[1],dictData.ret)
			end
		end
	end
 	local itemId = tonumber(pArrItemId[1].item_id)
	local args = Network.argsHandlerOfTable({itemId})
	Network.rpc(requestCallBack, "chariot.previewReborn", "chariot.previewReborn", args, true)
end

-------------------------------------------重生预览接口-----------------------------------------------