local common = import("..common.common")
local commonMenu = class("commonMenu", function ()
	return display.newNode()
end)

table.merge(slot1, {})

commonMenu.ctor = function (self, params)
	self.size(self, display.width, display.height)
	self.setTouchSwallowEnabled(self, true)
	self.setTouchEnabled(self, true)
	self.addNodeEventListener(self, cc.NODE_TOUCH_EVENT, function (event)
		if event.name == "began" then
			self:hidePanel()
		end

		return 
	end)
	self.createMenu(slot0, params.pos, params.name, params.id, params.align or 0)

	return 
end

local function relationOp(name, relationMark, ifAdd)
	if not name or name == "" then
		main_scene.ui:tip("名字不能为空！")

		return 
	end

	local rsb = DefaultClientMessage(CM_AddDelRelation)
	rsb.FTargetName = name
	rsb.FRelationMark = relationMark
	rsb.FIfAdd = ifAdd

	MirTcpClient:getInstance():postRsb(rsb)

	return 
end

commonMenu.createMenu = function (self, tPos, name, roleId, nAlign)
	local cellCfg = {}
	local interval = 6
	local operation = {}

	table.insert(operation, {
		title = "私聊",
		op = function ()
			common.changeChatStyle({
				{
					"target",
					name
				},
				{
					"channel",
					"私聊"
				}
			})

			return 
		end
	})
	table.insert(slot7, {
		title = "查看信息",
		op = function ()
			if roleId then
				if main_scene.ui.panels.equipOther and main_scene.ui.panels.equipOther.roleId == roleId then
					return 
				end

				local rsb = DefaultClientMessage(CM_QUERYUSERSTATE)
				rsb.FPlayerByID = roleId

				MirTcpClient:getInstance():postRsb(rsb)
			end

			return 
		end
	})

	local relation = g_data.relation.getRelationShip(slot8, name)

	if not relation.isFriend then
		table.insert(operation, {
			title = "添加好友",
			op = function ()
				relationOp(name, 0, true)

				return 
			end
		})
	else
		table.insert(slot7, {
			title = "删除好友",
			op = function ()
				relationOp(name, 0, false)

				return 
			end
		})
	end

	table.insert(slot7, {
		title = "邀请组队",
		op = function ()
			if #g_data.player.groupMembers == 0 then
				local rsb = DefaultClientMessage(CM_CreateGroup)
				rsb.FName = name

				MirTcpClient:getInstance():postRsb(rsb)
			else
				local rsb = DefaultClientMessage(CM_AddGroupMember)
				rsb.FName = name

				MirTcpClient:getInstance():postRsb(rsb)
			end

			return 
		end
	})
	table.insert(slot7, {
		title = "申请入队",
		op = function ()
			local rsb = DefaultClientMessage(CM_JoinGroup)
			rsb.FName = name

			MirTcpClient:getInstance():postRsb(rsb)

			return 
		end
	})

	if not relation.isAttention then
		table.insert(slot7, {
			title = "添加关注",
			op = function ()
				relationOp(name, 1, true)

				return 
			end
		})
	end

	if not relation.isBlack then
		table.insert(slot7, {
			title = "加黑名单",
			op = function ()
				relationOp(name, 2, true)

				return 
			end
		})
	end

	for k, v in ipairs(slot7) do
		local c = {
			w = 94,
			h = 41,
			idx = k - 1,
			op = v,
			cellCls = function ()
				local btn = an.newBtn(res.gettex2("pic/common/btn20.png"), function ()
					sound.playSound("103")

					return 
				end, {
					pressImage = res.gettex2("pic/common/btn21.png"),
					label = {
						c.op.title,
						20,
						0,
						{
							color = cc.c3b(240, 200, 150)
						}
					}
				}).anchor(c, 0, 0)

				btn.setTouchSwallowEnabled(btn, false)

				return btn
			end
		}
		cellCfg[k] = c
	end

	self.panel = common.createOperationMenu(slot5, interval, function (panel, cfg)
		if name and roleId then
			slot2 = cfg.op.op and cfg.op.op()
		end

		self:hidePanel()

		return 
	end, {
		width = 110,
		disPopStyle = true
	}).add2(slot9, self)

	if nAlign == 0 then
		self.panel:pos(tPos.x, tPos.y)
	elseif nAlign == 1 then
		local sizeP = self.panel:getContentSize()

		self.panel:pos(tPos.x, tPos.y - sizeP.height)
	end

	return 
end

return commonMenu
