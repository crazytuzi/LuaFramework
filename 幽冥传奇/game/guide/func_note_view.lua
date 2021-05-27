FuncNoteView = FuncNoteView or BaseClass()

function FuncNoteView:__init()
	self.is_modal = true
	self.root_node = nil
	self.is_open = false
end

function FuncNoteView:__delete()
end	

function FuncNoteView:Open(note_guide)
	if nil == self.root_node then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

		self.global_width = screen_w

		self.root_node = cc.Node:create()
		self.root_node:setAnchorPoint(0,0)
		HandleRenderUnit:AddUi(self.root_node, COMMON_CONSTS.ZORDER_MOVIE_GUIDE, COMMON_CONSTS.ZORDER_MOVIE_GUIDE)

	end

	local main_view = MainuiCtrl.Instance:GetView()
	local note_view = main_view:GetFuncNoteView()
	note_view:SetVisible(true)
	note_view:SetData(note_guide)

	if note_guide.state == ClientFuncNoteState.Noteing then --预告
		
	elseif note_guide.state == ClientFuncNoteState.Open then --飞展示
		if note_guide.spring == true then
			MainuiFuncNoteView:OnImgClick()
		end	

		if not self.is_open then

			ViewManager.Instance:CloseAllView() --关闭所有模块
			local is_switch = note_guide.is_switch_main or false
			MainuiCtrl.Instance:PushMainuiNavBtnToggle(is_switch)
			GuideCtrl.Instance:SetGuideViewVisible(false)
			note_view:SetEnabled(false)
			self.is_open = true


			local temp_x,temp_y = note_view:GetView():getPosition()
			local temp_icon = XUI.CreateImageView(temp_x,temp_y,ResPath.GetMainui("icon_" .. string.format("%02d",note_guide.icon) .. "_img"),true)
			self.root_node:addChild(temp_icon)
			temp_icon:setVisible(false)
			
			if note_guide.open_action.type == ClientGuideStepType.CommonButton then
			    node = ClientCommonButtonDic[note_guide.open_action.node_name]
			    if node == nil then
			    	node = ViewManager.Instance:GetUiNode(note_guide.open_action.view_name,note_guide.open_action.node_name)
			    end
			end

			

			local pos = cc.p(0,0)
			node = MainuiCtrl.Instance:GetManuiNavSkillSwitch()
			if node then
				if node.getContentSize == nil then
					node = node:GetView()
				end	
				if node and node:getParent() then
					-- local size = node:getContentSize()
					local size = temp_icon:getContentSize()
					local data =  GuideData.Instance:GetNewFuncNoteCfg()
					local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 人物等级
					local show_acts_data = {}
					local cur_max_idx = 0
					for k,v in pairs(data) do
						if role_level >= v.level then
							cur_max_idx = cur_max_idx + 1
							table.insert(show_acts_data, v)
						end	
					end
					if note_guide.spring == true then
						if cur_max_idx < #data then
							pos = node:convertToWorldSpace(cc.p(size.width * 0.5+360, size.height * 0.5+385))
						else
							pos = node:convertToWorldSpace(cc.p(size.width * 0.5+360, size.height * 0.5+157))
						end	
					else
						pos = node:convertToWorldSpace(cc.p(size.width * 0.5, size.height * 0.5))
					end	
				end
			end	

			local callback1 = cc.CallFunc:create(function()
				temp_icon:setVisible(true)
			end)

			local callback2 = cc.CallFunc:create(function()
				self.is_open = false
				temp_icon:removeFromParent()
	   			temp_icon = nil
	   			-- note_view:SetVisible(false)
	   			note_view:StopEffect()
	   			GuideCtrl.Instance:SetGuideViewVisible(true)
	   			note_view:SetEnabled(true)
	   			GuideCtrl.Instance:EndNoteGuide()
			end)
			note_view:PlayEffect()
			local delay = cc.DelayTime:create(1)
			local action = cc.Spawn:create(cc.MoveTo:create(2,pos))
			local queue = cc.Sequence:create(delay,callback1,action,callback2)
			temp_icon:runAction(queue)
		end	
		
	end	
end	

function FuncNoteView:OnClickLayout()
end


function FuncNoteView:Close()
	if nil ~= self.root_node then
		NodeCleaner.Instance:AddNode(self.root_node)
		self.root_node = nil
	end
end


