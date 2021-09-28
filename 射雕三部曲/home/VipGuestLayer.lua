--[[
    文件名：VipGuestLayer
    描述：vip贵宾页面
    创建人：chenzhong
    创建时间：2018.1.22
-- ]]

local VipGuestLayer = class("VipGuestLayer",function()
    return cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
end)

--[[
    params:
        callBack: 关闭时回调函数
--]]
function VipGuestLayer:ctor(params)
	-- 添加弹出框层
	local bgLayer = require("commonLayer.PopBgLayer").new({
		title = TR("贵宾会员"),
		bgSize = cc.size(630, 925),
		closeImg = "c_29.png",
		closeAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(bgLayer)

    -- 读取参数
    self.exitCallBack = params.callBack

	-- 保存弹窗控件信息
	self.bgSprite = bgLayer.mBgSprite
	self.bgSize = bgLayer.mBgSprite:getContentSize()

	-- 初始化UI
	self:initUI()

	self:requestInfo()
end

function VipGuestLayer:initUI()
    --背景
    local bgSprite = ui.newSprite("gbhy_1.png")
    bgSprite:setPosition(self.bgSize.width*0.5, self.bgSize.height*0.5+20)
    self.bgSprite:addChild(bgSprite)

    -- 添加文字描述
    self:addText()

    local tempLabel = ui.newLabel({
    	text = TR("大侠，您已升级为我们的贵宾用户，添加贵宾顾问QQ开启尊享体验！"),
    	color = cc.c3b(0xff, 0xf9, 0xeb),
    	size = 18,
    })
    tempLabel:setPosition(self.bgSize.width*0.5, 175)
    self.bgSprite:addChild(tempLabel)

    -- 客服QQ
    local serviceQQStr = "3395126412"
    local qqTempBg = ui.newSprite("gbhy_3.png")
    qqTempBg:setPosition(self.bgSize.width*0.5-50, 140)
    self.bgSprite:addChild(qqTempBg)

    local qqLabel = ui.newLabel({
    	text = TR("贵宾顾问QQ：%s", serviceQQStr),
    	color = cc.c3b(0xff, 0xe7, 0x49),
    	size = 18,
    })
    qqLabel:setPosition(qqTempBg:getContentSize().width*0.5, qqTempBg:getContentSize().height*0.5)
    qqTempBg:addChild(qqLabel)
    -- 复制按钮
    local fzBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("复制"),
        clickAction = function()
            if IPlatform:getInstance().copyWords then
                IPlatform:getInstance():copyWords(serviceQQStr)
            end
        end
    })
    fzBtn:setPosition(475, 140)
    fzBtn:setScale(0.8)
    self.bgSprite:addChild(fzBtn)
    -- 输入背景
    local tempBgSprite = ui.newScale9Sprite("c_17.png", cc.size(565, 65))
    tempBgSprite:setPosition(self.bgSize.width*0.5, 60)
    self.bgSprite:addChild(tempBgSprite)
    -- 输入框
    local inputEditBox = ui.newEditBox({
        image = "c_83.png",
        size  = cc.size(400, 30),
        maxLength = 11,
        multiLines = true,
        fontColor = cc.c3b(0x46, 0x22, 0x0d),
        placeHolder = TR("请留下您的个人QQ，方便贵宾顾问进行验证"),
        placeColor = cc.c3b(0x46, 0x22, 0x0d),
        fontSize = 20,
    })
    inputEditBox:setAnchorPoint(cc.p(0, 0.5))
    inputEditBox:setPosition(60, 60)
    self.bgSprite:addChild(inputEditBox)
    self.mInputEditBox = inputEditBox

    -- 提交按钮    
    local tjBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("提交"),
        clickAction = function()
            local qqStr = string.trim(inputEditBox:getText())

            if not qqStr or qqStr == "" then
                ui.showFlashView({text = TR("请输入你的QQ号")})
                return
            end

            local yanzheng = tonumber(qqStr)
            if not yanzheng then
                ui.showFlashView({text = TR("请输入正确的QQ号")})
                return
            elseif yanzheng and string.len(qqStr) < 5 then
                ui.showFlashView({text = TR("输入的QQ号码过短")})
                return
            end

            self:requestTjQQ(qqStr)
        end
    })
    tjBtn:setPosition(530, 60)
    tjBtn:setScale(0.8)
    self.bgSprite:addChild(tjBtn)
    self.mTjBtn = tjBtn
end

function VipGuestLayer:addText()
    local function addInfoLabel(strText, pos, textColor, textSize, dimon, outColor)
        local label = ui.newLabel({
            text = strText, 
            color = textColor or cc.c3b(0x46, 0x22, 0x0d), 
            size = textSize or 18,
            -- outlineColor = outColor or cc.c3b(0xff, 0xff, 0xff),
        })
        label:setAnchorPoint(cc.p(0, 0))
        label:setPosition(pos)
        if dimon then 
            label:setDimensions(dimon)
        end    
        if outColor then
            label:enableOutline(outColor, 2)
        end      
        self.bgSprite:addChild(label, 1)
    end

    addInfoLabel(TR("{gbhy_2.png}  1.快速解答"), cc.p(60, 690), cc.c3b(0xff, 0xe7, 0x49), 18)
    addInfoLabel(TR("细致贴心的问题解答"), cc.p(70, 660), cc.c3b(0xff, 0xed, 0xb6), 18)
    addInfoLabel(TR("{gbhy_2.png}  2.专业处理"), cc.p(60, 610), cc.c3b(0xff, 0xe7, 0x49), 18)
    addInfoLabel(TR("专业快速的处理通道"), cc.p(60, 580), cc.c3b(0xff, 0xed, 0xb6), 18)
    addInfoLabel(TR("{gbhy_2.png}  3.贴心的关怀"), cc.p(60, 520), cc.c3b(0xff, 0xe7, 0x49), 18)
    addInfoLabel(TR("别具一格的个性关怀"), cc.p(60, 490), cc.c3b(0xff, 0xed, 0xb6), 18)
    addInfoLabel(TR("{gbhy_2.png}  4.贵宾定制"), cc.p(60, 440), cc.c3b(0xff, 0xe7, 0x49), 18)
    addInfoLabel(TR("享受更多贵宾定制服务"), cc.p(60, 410), cc.c3b(0xff, 0xed, 0xb6), 18)
end

-- 刷新页面
function VipGuestLayer:refreshUI()
	-- 状态2为已提交
	self.mInputEditBox:setEnabled(not (self.mSvipInfo.State == 2))
	self.mTjBtn:setEnabled(not (self.mSvipInfo.State == 2))
	self.mTjBtn:setTitleText(self.mSvipInfo.State == 2 and TR("已提交") or TR("提交"))

	self:refreshReward()
end

-- 刷新奖励列表
function VipGuestLayer:refreshReward()
	if not self.mRewardCardList then
		local resList = Utility.analysisStrResList(self.mVipConfig.Reward or "")
		self.mRewardCardList = ui.createCardList({
			maxViewWidth = 400,
			cardDataList = resList,
		})
		self.mRewardCardList:setAnchorPoint(cc.p(0, 0.5))
		self.mRewardCardList:setPosition(60, 300)
		self.bgSprite:addChild(self.mRewardCardList)
	else	
		local resList = Utility.analysisStrResList(self.mVipConfig.Reward or "")
		self.mRewardCardList.refreshList(resList)
	end

end

----------------------------网络相关------------------------
-- 请求数据
function VipGuestLayer:requestInfo()
	HttpClient:request({
        moduleName = "Svip",
        methodName = "GetInfo",
        callbackNode = self,
        svrMethodData = {},
        callback = function(data)
            -- 容错处理
            if data.Status ~= 0 then
                return
            end
            local allConfig = data.Value.SvipPreviewConfig
            self.mVipConfig = {}
            for _, configInfo in pairs(allConfig) do
            	if configInfo.ShowStartDate < Player:getCurrentTime() and configInfo.ShowEndDate > Player:getCurrentTime() then
            		self.mVipConfig = configInfo
            		break
            	end
            end
            self.mSvipInfo = data.Value.SvipInfo

            self:refreshUI()
        end
    })
end

-- 提交QQ号
function VipGuestLayer:requestTjQQ(qqStr)
	HttpClient:request({
        moduleName = "Svip",
        methodName = "CommitQQ",
        callbackNode = self,
        svrMethodData = {qqStr},
        callback = function(data)
            -- 容错处理
            if data.Status ~= 0 then
                return
            end
            ui.showFlashView({text = TR("提交成功,我们将在第一时间联系到你")})

            self.mSvipInfo.State = 2

            self:refreshUI()

            -- 刷新主界面显示
            if self.exitCallBack then
                self.exitCallBack()
            end
        end
    })
end

return VipGuestLayer