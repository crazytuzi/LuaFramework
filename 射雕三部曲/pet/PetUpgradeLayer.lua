--[[
	文件名：PetUpgradeLayer.lua
	描述：外功秘籍培养页面
	创建人：peiyaoqiang
    创建时间：2017.03.21
--]]

local PetUpgradeLayer = class("PetUpgradeLayer", function(params)
	return display.newLayer()
end)

-- 构造函数
--[[
	params:
	Table params:
	{
        petList             -- 必传参数，外功秘籍列表(因为支持滑动切换)
		currIndex 			-- 必传参数，当前需要展示的外功秘籍在外功秘籍列表中的序号（对应阵容的卡槽序号）
		pageType 			-- 可选参数，页面类型，进入页面时显示哪个子页面，在EnumsConfig.lua中的ModuleSub定义
							-- 升级   ModuleSub.ePetLvUp
							-- 参悟   ModuleSub.ePetActiveTal
	}
--]]
function PetUpgradeLayer:ctor(params)
    -- 屏蔽点击事件
    ui.registerSwallowTouch({node = self})

    -- 保存数据
    self.mPetList = params.petList
    self.mCurrIndex = params.currIndex
    self.mPageType = params.pageType or ModuleSub.ePetLvUp

    -- 添加UI
    self:initUI()
end

-- 初始化UI
function PetUpgradeLayer:initUI()
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 背景列表
    local bgList = {
        [ModuleSub.ePetLvUp] = "wgmj_17.jpg",
        [ModuleSub.ePetActiveTal] = "wgcw_01.jpg"
    }
    self.mBgSpriteList = {}
    for k, v in pairs(bgList) do
        self.mBgSpriteList[k] = ui.newSprite(v)
        self.mBgSpriteList[k]:setPosition(320, 568)
        self.mParentLayer:addChild(self.mBgSpriteList[k])
        self.mBgSpriteList[k]:setOpacity(0)
    end
    self.mBgSpriteList[self.mPageType]:setOpacity(255)

    -- 顶部底部所在layer
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {
            ResourcetypeSub.ePetEXP, 
            {
                resourceTypeSub = 1605, 
                modelId = 16050100,
            },
            ResourcetypeSub.eGold, 
        },
    })
    self:addChild(self.mCommonLayer)

    -- 容器节点，下方的元素添加于此
    self.mChildLayer = display.newLayer()
    self.mParentLayer:addChild(self.mChildLayer)

    -- 添加分页控件
    self:addTabView()

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)
end

--------------------数据恢复-----------------------
function PetUpgradeLayer:getRestoreData()
    local retData = {
        petList = self.mPetList,
        currIndex = self.mCurrIndex,
        pageType = self.mPageType
    }
    return retData
end

-- 添加分页控件
function PetUpgradeLayer:addTabView()
    -- 添加黑底
    local decBgSize = cc.size(640, 97)
    local decBg = ui.newScale9Sprite("c_73.png", decBgSize)
    decBg:setPosition(cc.p(320, 1053))
    self.mParentLayer:addChild(decBg)

	local buttonInfos = {
        {
            text = TR("升级"),
            tag = ModuleSub.ePetLvUp
        },
        {
            text = TR("参悟"),
            tag = ModuleSub.ePetActiveTal
        }
    }

    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        viewSize = cc.size(640, 80),
        btnSize = cc.size(138, 56),
        needLine = true,
        defaultSelectTag = self.mPageType,
        allowChangeCallback = function(btnTag)
            if btnTag == ModuleSub.ePetLvUp then                -- 升级页面跳转条件
                return true
            elseif btnTag == ModuleSub.ePetActiveTal then       -- 参悟页面跳转条件
                -- 当前选中的外功秘籍模型
                local currPetModel = PetModel.items[self.mPetList[self.mCurrIndex].ModelId]
                if currPetModel.valueLv < 3 then
                    ui.showFlashView({
                        text = TR("蓝色及以上品质外功秘籍才有参悟系统")
                    })
                    return false
                else
                    return true
                end
            end
        end,
        onSelectChange = function(selectBtnTag)
            -- 老的背景淡出
            self.mBgSpriteList[self.mPageType]:runAction(cc.FadeOut:create(0.75))

        	self.mPageType = selectBtnTag

            -- 新的背景淡入
            self.mBgSpriteList[self.mPageType]:runAction(cc.FadeIn:create(0.75))

            -- 先移除再重新添加
            self.mChildLayer:removeAllChildren()

            if self.mPageType == ModuleSub.ePetLvUp then
                local layerParams = {
                    petList = self.mPetList,
                    currIndex = self.mCurrIndex,
                    callback = function(petList, currIndex)
                        self.mPetList = petList
                        self.mCurrIndex = currIndex
                    end
                }
                local petLvUpLayer = require("pet.PetLvUpLayer"):create(layerParams)
                self.mChildLayer:addChild(petLvUpLayer)
            elseif self.mPageType == ModuleSub.ePetActiveTal then
                local layerParams = {
                    petList = self.mPetList,
                    currIndex = self.mCurrIndex,
                    callback = function(petList, currIndex)
                        self.mPetList = petList
                        self.mCurrIndex = currIndex
                    end
                }
                local petTalentLayer = require("pet.PetTalentLayer"):create(layerParams)
                self.mChildLayer:addChild(petTalentLayer)
            end
        end
    })
    tabLayer:setAnchorPoint(cc.p(0.5, 1))
    tabLayer:setPosition(320, 1080)
    self.mParentLayer:addChild(tabLayer)
end

return PetUpgradeLayer
