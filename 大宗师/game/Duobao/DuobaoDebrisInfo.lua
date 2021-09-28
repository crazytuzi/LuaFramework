--[[
 --
 -- add by vicky
 -- 2014.08.15
 --
 --]]
  
 local data_ui_ui = require("data.data_ui_ui") 

 local DuobaoDebrisInfo = class("DuobaoDebrisInfo", function()
		return require("utility.ShadeLayer").new()
	end)


 function DuobaoDebrisInfo:getSnatchList()
 	RequestHelper.Duobao.getSnatchList({
 		id = tostring(self._id), 
        callback = function(data)
            self:initDuobaoListScene(data)
        end
        })
 end


 function DuobaoDebrisInfo:initDuobaoListScene(data) 
 	if string.len(data["0"]) > 0 then
 		show_tip_label(data["0"]) 
 		self._snatchBtn:setEnabled(true) 
 		return 
 	end 

 	local warFreeTime = 0 
 	if self._getMianzhanTime ~= nil then 
 		warFreeTime = self._getMianzhanTime() 
 	end 

	push_scene(require("game.Duobao.DuobaoQiangduoListScene").new({
		data = data, 
		id = self._id, 
		title = self._title, 
		warFreeTime = warFreeTime 
		}))

	self:removeFromParentAndCleanup(true)
 end

 function DuobaoDebrisInfo:onExit()
 	TutoMgr.removeBtn("qiangduo_info_btn")
 end

 function DuobaoDebrisInfo:onEnter()
 	
 	TutoMgr.addBtn("qiangduo_info_btn",self.tutoBtn)
 	TutoMgr.active()
 end

 
 function DuobaoDebrisInfo:ctor(param)
 	self._id = param.id 
 	self._getMianzhanTime = param.getMianzhanTime 
 	self:setNodeEventEnabled(true)


 	self.closeListener = param.closeListener


 	local proxy = CCBProxy:create()
 	local rootnode = {}

 	local node = CCBuilderReaderLoad("duobao/duobao_debris_info.ccbi", proxy, rootnode)
 	node:setPosition(display.width/2, display.height/2)
	self:addChild(node)

	rootnode["closeBtn"]:addHandleOfControlEvent(function(eventName,sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi)) 
                sender:runAction(transition.sequence({
                CCCallFunc:create(function()
                	if(self.closeListener ~= nil) then
                		self.closeListener()
                	end
                    self:removeFromParentAndCleanup(true)
                end)
            }))
            end,
            CCControlEventTouchUpInside)

	self._snatchBtn = rootnode["snatchBtn"] 
	self._snatchBtn:addHandleOfControlEvent(function()
        	if(self.closeListener ~= nil) then
        		self.closeListener()
        	end
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
				PostNotice(NoticeKey.REMOVE_TUTOLAYER)
				self._snatchBtn:setEnabled(false) 
				self:getSnatchList()
            end,
            CCControlEventTouchUpInside)
	self.tutoBtn = rootnode["snatchBtn"]

	-- icon
	local resType = ResMgr.getResType(param.type)
	ResMgr.refreshIcon({itemBg = rootnode["icon"], id = self._id, resType = resType})

	-- name
	self._title = param.title
	-- rootnode["nameLbl"]:setString(self._title)
	-- rootnode["nameLbl"]:setColor(ResMgr.getItemNameColor(self._id)) 

	local nameColor = ResMgr.getItemNameColor(self._id)  
	local nameLbl = ui.newTTFLabelWithShadow({
        text = self._title,
        size = 24,
        color = nameColor,
        shadowColor = ccc3(0, 0, 0), 
        font = FONTS_NAME.font_fzcy,
        align = ui.TEXT_ALIGN_LEFT
        })
		
	nameLbl:setPosition(0, nameLbl:getContentSize().height/2)
	rootnode["nameLbl"]:removeAllChildren()
    rootnode["nameLbl"]:addChild(nameLbl)


	-- describe
	rootnode["describeLbl"]:setString(param.describe) 

	rootnode["bottom_describe_lbl"]:setString(data_ui_ui[3].content)

	if(param.num > 0) then 
		rootnode["numDescLbl"]:setVisible(true)
		rootnode["snatchBtn"]:setVisible(false)
		rootnode["numLbl"]:setString("当前拥有数量：" .. tostring(param.num))
	else 
		rootnode["numDescLbl"]:setVisible(false)
		rootnode["snatchBtn"]:setVisible(true)
	end

 end



 return DuobaoDebrisInfo