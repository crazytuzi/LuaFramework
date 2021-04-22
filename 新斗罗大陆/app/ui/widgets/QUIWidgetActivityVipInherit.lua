-- @Author: zhouxiaoshu
-- @Date:   2019-07-04 16:30:58
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-08-13 16:34:25

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityVipInherit = class("QUIWidgetActivityVipInherit", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")
local QVIPUtil = import("...utils.QVIPUtil")

local normal_color = ccc3(126, 19, 20)
local stress_color = ccc3(198, 48, 50)


function QUIWidgetActivityVipInherit:ctor()
	local ccbFile = "ccb/Widget_vip_inherit.ccbi"
  	local callBacks = {
  		{ccbCallbackName = "onTriggerOK", callback = handler(self, QUIWidgetActivityVipInherit._onTriggerOK)},
  	}
	QUIWidgetActivityVipInherit.super.ctor(self,ccbFile,callBacks,options)

	self._richText = QRichText.new({}, 470)
	self._richText:setAnchorPoint(ccp(0.5, 0.5))
    self._ccbOwner.node_desc:addChild(self._richText)

    self._ccbOwner.node_ok:setVisible(false)
    self._ccbOwner.sp_ok:setVisible(false)
    self._ccbOwner.tf_time:setString("")
    self._ccbOwner.node_tf_time:setPositionY(-display.height/2)

    app:getClient():getWarmBloodVipExpInfo(function( data )
            if self:safeCheck() and data then
                self._info = data.warmBloodServerUserVipInfo or {}
                self:updateInfo()
            end
        end)
end

function QUIWidgetActivityVipInherit:setInfo()
end

function QUIWidgetActivityVipInherit:updateInfo()
    self._ccbOwner.tf_time:setString("永久存在")
    local recharge = self._info.exp or 0     -- 充值额度
    local item = QUIWidgetItemsBox.new()
    self._ccbOwner.node_icon:addChild(item)
    item:setPromptIsOpen(true)

    if recharge > 0 then
        self._exp = recharge*10
        item:setGoodsInfo(nil, ITEM_TYPE.VIP_EXP, self._exp)
    	self._richText:setString({
            {oType = "font", content = "活动介绍：您在<新斗罗大陆>的", size = 22, color = normal_color
            --, strokeColor = COLORS.k
            },
            {oType = "font", content = self._info.gameAreaName or "", size = 22, color = stress_color
            --, strokeColor = COLORS.k
            },
            {oType = "font", content = "服务器中充值额度达到了", size = 22, color = normal_color
            --, strokeColor = COLORS.k
            },
        	{oType = "font", content = tostring(recharge), size = 22, color = stress_color
            --, strokeColor = COLORS.k
            },
            {oType = "font", content = "元，获得了超级服100%vip经验返还的特权，所有经验将在登录时全部返还给您~", size = 22, color = normal_color
            --, strokeColor = COLORS.k
            },
        })
    else
        local vipLevel = db:getConfiguration()["warm_blood_vip_extend"].value
        self._exp = QVIPUtil:cash(vipLevel)
        item:setGoodsInfo(nil, ITEM_TYPE.VIP_EXP, self._exp)
        self._richText:setString({
            {oType = "font", content = "活动介绍：超级开服送福利，所有在老区没有账号的充值额度达到", size = 22, color = normal_color
            --, strokeColor = COLORS.k
            },
            {oType = "font", content = "100", size = 22, color = stress_color
            --, strokeColor = COLORS.k
            },
            {oType = "font", content = "元以上的玩家都将获得vip福利，领取", size = 22, color =  normal_color
            --, strokeColor = COLORS.k
            },
            {oType = "font", content = tostring(self._exp), size = 22, color = stress_color
            --, strokeColor = COLORS.k
            },
            {oType = "font", content = "vip经验，还有别的冲级福利等你来拿哦~", size = 22, color = normal_color
            --, strokeColor = COLORS.k
            },
        })
    end

    self._ccbOwner.node_ok:setVisible(not remote.user.warmBloodVipGet)
    self._ccbOwner.sp_ok:setVisible(remote.user.warmBloodVipGet)
end

function QUIWidgetActivityVipInherit:updateGetInfo()
    self._ccbOwner.node_ok:setVisible(not remote.user.warmBloodVipGet)
    self._ccbOwner.sp_ok:setVisible(remote.user.warmBloodVipGet)
end

function QUIWidgetActivityVipInherit:_onTriggerOK(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    app.sound:playSound("common_small")

    local oldVipLevel = QVIPUtil:VIPLevel()
    local awards = {} 
    table.insert(awards, {id = nil, typeName = ITEM_TYPE.VIP_EXP, count = self._exp})
	app:getClient():getWarmBloodVipExp(function (data)
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVipLevelUpSuccess",
            options = {oldVipLevel = oldVipLevel}})
        -- local dialog = app:alertAwards({awards = awards})
		-- dialog:setTitle("恭喜您获得活动奖励")
        remote.activity:refreshActivity()
        if self:safeCheck() then
            self:updateGetInfo()
        end
	end)
end

return QUIWidgetActivityVipInherit
