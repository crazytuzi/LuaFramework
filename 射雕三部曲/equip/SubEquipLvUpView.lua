--[[
	文件名:SubEquipLvUpView.lua
	描述：装备强化的子页面
	创建人：peiyaoqiang
	创建时间：2017.05.12
--]]

local SubEquipLvUpView = class("SubEquipLvUpView", function(params)
    return cc.Node:create()
end)

--[[
-- 参数 params 中各项为：
	{
		viewSize: 显示大小，必选参数
		equipId:  装备实例Id，必选参数
		callback: 回调接口，可选参数
	}
]]
function SubEquipLvUpView:ctor(params)
	params = params or {}
	
	-- 读取参数
	self.viewSize = params.viewSize
	self.equipId = params.equipId
	self.callback = params.callback
	
	-- 初始化
	self:setContentSize(self.viewSize)
	self.currLv = 0
	self.maxLv = math.min(HeroObj:getMainHero().Lv * 2, table.maxn(EquipLvUpRelation.items))
	
	-- 显示界面
	self:initUI()
	self:refreshUI()
end

-- 初始化UI
function SubEquipLvUpView:initUI()
	-- 创建灰色背景图
	local centerBgSize = cc.size(self.viewSize.width - 40, self.viewSize.height - 220)
	local centerBgSprite = ui.newScale9Sprite("c_38.png", centerBgSize)
	centerBgSprite:setAnchorPoint(cc.p(0.5, 0))
	centerBgSprite:setPosition(cc.p(self.viewSize.width / 2, 160))
	self:addChild(centerBgSprite)

	-- 创建箭头
	local arrowSprite = ui.newSprite("c_67.png")
	arrowSprite:setPosition(centerBgSize.width * 0.5 - 5, centerBgSize.height * 0.5)
	centerBgSprite:addChild(arrowSprite)

	-- 创建属性背景图
	local function createAttrBg(posX)
		local attrBgSprite = ui.newScale9Sprite("c_54.png", cc.size(centerBgSize.width * 0.4, 150))
		attrBgSprite:setPosition(posX, centerBgSize.height * 0.5)
		attrBgSprite.addTitle = function(target, titleText)
			local titleLabel = ui.newLabel({
		        text = titleText,
		        size = 24,
		        color = Enums.Color.eWhite,
		        outlineColor = cc.c3b(0x8d, 0x4b, 0x3b),
		        outlineSize = 2,
		    })
		    titleLabel:setPosition(centerBgSize.width * 0.2, 150 - 22)
		    target:addChild(titleLabel)
		end
		centerBgSprite:addChild(attrBgSprite)
		return attrBgSprite
	end
	self.oldAttrBg = createAttrBg(centerBgSize.width * 0.23)
	self.newAttrBg = createAttrBg(centerBgSize.width * 0.77)
	
	-- 强化等级Label
	local lvUpLabel = ui.newLabel({
		text = "",
		color = cc.c3b(0x46, 0x22, 0x0d),
	})
	lvUpLabel:setAnchorPoint(cc.p(0.5, 0.5))
	lvUpLabel:setPosition(self.viewSize.width * 0.2, 110)
	self:addChild(lvUpLabel)
	self.lvUpLabel = lvUpLabel

	-- 强化消耗Label
	local useGoldNode = ui.createDaibiView({
		resourceTypeSub = ResourcetypeSub.eGold,
        number = 0,
        showOwned = true,
        fontColor = cc.c3b(0x46, 0x22, 0x0d),
	})
	useGoldNode:setAnchorPoint(cc.p(0.5, 0.5))
	useGoldNode:setPosition(self.viewSize.width * 0.8, 110)
	self:addChild(useGoldNode)
	self.useGoldNode = useGoldNode

	-- 详细属性按钮
	local btnDetail = ui.newButton({
		normalImage = "c_33.png",
		text = TR("详细属性"),
		clickAction = function()
			LayerManager.addLayer({
	            name = "equip.EquipInfoLayer",
	            data = {equipId = self.equipId,},
	            cleanUp = false
	        })
		end
	})
	btnDetail:setPosition(self.viewSize.width * 0.2, 60)
	self:addChild(btnDetail)

	-- 强化十次按钮
	local btnTen = ui.newButton({
		normalImage = "c_28.png",
		text = TR("强化十次"),
		clickAction = function()
			self:requestLvUp(10)
		end
	})
	btnTen:setPosition(self.viewSize.width * 0.5, 60)
	self:addChild(btnTen)

	-- 强化一次按钮
	local btnOne = ui.newButton({
		normalImage = "c_28.png",
		text = TR("强化"),
		clickAction = function()
			self:requestLvUp(1)
		end
	})
	btnOne:setPosition(self.viewSize.width * 0.8, 60)
	self:addChild(btnOne)
end

-- 刷新界面
function SubEquipLvUpView:refreshUI()
	local equipInfo = EquipObj:getEquip(self.equipId)
	local equipBase = EquipModel.items[equipInfo.ModelId]
	local currStar = equipInfo.Star or 0
	
	self.currLv = equipInfo.Lv or 0
	
	-- 重建属性
	local function resetAttrShow(attrBg, titleText, level)
		attrBg:removeAllChildren()
		attrBg:addTitle(TR(titleText))

		local attrList = {
			{posY = 86, text = FightattrName[Fightattr.eHP], attrBase = "HP", attrUp = "HPUP"},
			{posY = 54, text = FightattrName[Fightattr.eAP], attrBase = "AP", attrUp = "APUP"},
			{posY = 22, text = FightattrName[Fightattr.eDEF], attrBase = "DEF", attrUp = "DEFUP"},
		}
		local starId = equipBase.valueLv * 100 + currStar
		local starBase = EquipStarRelation.items[starId] or {}
		local addAttrR = starBase.curAddAttrR or 0
		for _,v in ipairs(attrList) do
			local tempPerAttr = equipBase[v.attrUp] * (1 + addAttrR)
			local tempAllAttr = "??"
			if (EquipLvUpRelation.items[level] ~= nil) then
				tempAllAttr = math.floor(tempPerAttr * level + equipBase[v.attrBase] * (1 + addAttrR))
			end
			local tempLabel = ui.newLabel({
				text = string.format("%s: %s%s", v.text, "#087E05", tempAllAttr),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 22,
			})
			tempLabel:setAnchorPoint(cc.p(0, 0.5))
			tempLabel:setPosition(50, v.posY)
			attrBg:addChild(tempLabel)
		end
	end
	resetAttrShow(self.oldAttrBg, TR("当前属性"), self.currLv)
	resetAttrShow(self.newAttrBg, TR("强化属性"), self.currLv + 1)

	-- 刷新强化等级
	self.lvUpLabel:setString(TR("强化等级:%d/%d", self.currLv, self.maxLv))

	-- 刷新强化消耗
	self.nUseGold = math.floor(EquipLvUpRelation.items[self.currLv].perExp * equipBase.upUseR)
	self.useGoldNode.setNumber(self.nUseGold)
end

-- 强化接口
function SubEquipLvUpView:requestLvUp(count)
	-- 判断是否超过玩家等级的2倍
	local limitLv = HeroObj:getMainHero().Lv * 2
	if (self.currLv >= limitLv) then
		ui.showFlashView(TR("装备等级不能超过玩家等级的2倍"))
		return
	end
	
	-- 判断是否已经满级
	if (self.currLv >= self.maxLv) then
		ui.showFlashView(TR("该装备已经强化到满级"))
		return
	end

	-- 判断铜钱是否足够
	if not Utility.isResourceEnough(ResourcetypeSub.eGold, self.nUseGold, true) then
		--ui.showFlashView(TR("铜钱不足"))
		return
	end

	-- 请求接口
	HttpClient:request({
        moduleName = "Equip",
        methodName = "EquipLvUpForCount",
        svrMethodData = {self.equipId, count},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return 
            end

            -- 刷新缓存
            EquipObj:modifyEquipItem(response.Value.EquipInfo)

            -- 弹出升级提示
            if (count == 1) then
            	local upLv = tonumber(response.Value.LvUpList[1])
            	if (upLv > 1) then
            		ui.showFlashView(TR("强化暴击！等级+%d", upLv))
            	else
            		ui.showFlashView(TR("强化成功！等级+%d", upLv))
            	end
            else
            	local upLv = 0
				for _, lv in ipairs(response.Value.LvUpList) do
					upLv = upLv + tonumber(lv)
				end
				ui.showFlashView(TR("强化成功！等级+%d", upLv))
            end

            -- 执行回调
            if (self.callback ~= nil) then
            	self.callback(ModuleSub.eEquipLvUp)
            end
        end
    })
end

return SubEquipLvUpView