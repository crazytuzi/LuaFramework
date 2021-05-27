
-- 必杀技预告
BiShaPreviewView = BiShaPreviewView or BaseClass(BaseView)

function BiShaPreviewView:__init()
	-- self:SetModal(true)
	self.is_async_load = false
	self:SetIsAnyClickClose(true)
	self.texture_path_list = {}
	self.config_tab = {
		{"bishaji_ui_cfg", 1, {0}},
	}
end

function BiShaPreviewView:__delete()
end

function BiShaPreviewView:ReleaseCallBack()
end

function BiShaPreviewView:LoadCallBack(index, loaded_times)
	-- local size = self:GetRootNode():getContentSize()
	-- local icon = self:GetViewManager():GetUiNode("MainUi", "BiShaPreview")
	-- local icon_pos = cc.p(icon:getPosition())
	-- local local_pos = self:GetRootNode():convertToNodeSpace(icon_pos)
	-- self.node_t_list.layout_bishiji.node:setPosition(local_pos.x, local_pos.y)

	local anim_path, anim_name = ResPath.GetEffectAnimPath(28)
	local eff = RenderUnit.CreateAnimSprite(anim_path, anim_name, nil, nil, false, nil)
	eff:setScale(0.5)
	eff:setPosition(498, 80)
	self.node_t_list.layout_bishiji.node:addChild(eff, 99)
end

function BiShaPreviewView:OpenCallBack()
end

function BiShaPreviewView:CloseCallBack(is_all)
end

function BiShaPreviewView:ShowIndexCallBack(index)
	local node = self.node_t_list.layout_bishiji.node
	node:stopAllActions()
	local size = self:GetRootNode():getContentSize()
	node:setAnchorPoint(1, 1)
	node:setPosition(size.width, size.height)
	node:setScale(0)
	local act = cc.EaseBackOut:create(cc.ScaleTo:create(0.35, 1))
	node:runAction(act)
end

function BiShaPreviewView:OnFlush(param_t, index)
end
--------------------------------------------------------
function BiShaPreviewView:SetVisible(visible)
	if self.is_popup ~= visible and nil ~= self.real_root_node then
		self.is_popup = visible

		if not self.is_popup and nil ~= self.node_t_list.layout_bishiji then
			local node = self.node_t_list.layout_bishiji.node
			node:stopAllActions()
			-- local act = cc.EaseBackIn:create(cc.ScaleTo:create(0.3, 0))
			local act = cc.ScaleTo:create(0.2, 0)
			node:runAction(cc.Sequence:create(act, cc.CallFunc:create(function()
				self.real_root_node:setVisible(visible)
			end)))
		else
			self.real_root_node:setVisible(visible)
		end
	end
end
--------------------------------------------------------