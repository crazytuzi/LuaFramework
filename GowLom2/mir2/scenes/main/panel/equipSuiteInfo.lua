local info = {
	show = function (data, scenePos, params)
		local maxWidth = 300
		local layer = display.newNode():size(display.width, display.height):addto(params.parent or display.getRunningScene(), params.z or an.z.max)

		layer.setTouchEnabled(layer, true)
		layer.setTouchSwallowEnabled(layer, false)

		if not params.fromSmelting then
			layer.addNodeEventListener(layer, cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
				if event.name == "ended" then
					g_data.player.showTips = false

					layer:runs({
						cc.DelayTime:create(0.01),
						cc.RemoveSelf:create(true)
					})

					info.layer = nil
				end

				return true
			end)
		end

		info.layer = layer
		local bg = display.newScale9Sprite(res.getframe2("pic/scale/scale24.png")).addto(slot5, layer):anchor(0, 1)
		local suiteColors = {
			def.colors.C3794fb,
			def.colors.Ccf15e1,
			def.colors.Cf1ed02
		}
		local h = 112
		local w = 250

		for i, v in ipairs(data) do
			if not v.FBoAct then
				h = h + 25
			else
				local suiteInfo = def.equipSuite.getSuiteByTypeAndLevel(v.FESType, v.FESLv)
				local props = def.equipSuite.dumpPropertyStr(suiteInfo.PropertyStr, params.job or g_data.player.job)
				h = h + #props*25

				if suiteInfo.SpecShapeName and suiteInfo.SpecShapeName ~= "" then
					h = h + 25
					local speProps = def.equipSuite.dumpPropertyStr(suiteInfo.SpePropStr, params.job or g_data.player.job)
					h = h + #speProps*25

					if v.FBoAct and v.FBoEffect and params.bSelf then
						h = h + 50
					end
				end
			end
		end

		bg.size(bg, w, h)
		an.newLabel("套装属性", 22, 0, {
			color = def.colors.Cf0c896
		}):addto(bg, 99):pos(10, h - 32):anchor(0, 0)

		local posY = h - 57

		for k, v in ipairs(data) do
			local hasDressNum = v.FHaveEquipNum or 0
			local suiteInfo = def.equipSuite.getSuiteByTypeAndLevel(v.FESType, v.FESLv)
			local props = def.equipSuite.dumpPropertyStr(suiteInfo.PropertyStr, params.job or g_data.player.job)

			an.newLabel(suiteInfo.ESName, 18, 0, {
				color = suiteColors[k] or cc.c3b(220, 210, 190)
			}):addto(bg, 99):pos(10, posY):anchor(0, 0)

			if suiteInfo.EquipNum <= hasDressNum then
				hasDressNum = suiteInfo.EquipNum

				an.newLabel(suiteInfo.ESTypeName .. "(" .. hasDressNum .. "/" .. suiteInfo.EquipNum .. ")", 18, 0, {
					color = def.colors.Cfad264
				}):addto(bg, 99):pos(125, posY):anchor(0, 0)
			else
				local lb1 = an.newLabel(suiteInfo.ESTypeName .. "(", 18, 0, {
					color = cc.c3b(220, 210, 190)
				}):addto(bg, 99):pos(125, posY):anchor(0, 0)
				local lb2 = an.newLabel(hasDressNum, 18, 0, {
					color = def.colors.Cf30302
				}):addto(bg, 99):pos(lb1.getw(lb1) + 125, posY):anchor(0, 0)

				an.newLabel("/" .. suiteInfo.EquipNum .. ")", 18, 0, {
					color = cc.c3b(220, 210, 190)
				}):addto(bg, 99):pos(lb1.getw(lb1) + 125 + lb2.getw(lb2), posY):anchor(0, 0)
			end

			posY = posY - 25
			local stateSp = "es_wjh.png"

			if v.FBoAct and v.FBoEffect then
				stateSp = "es_ysx.png"
			elseif v.FBoAct and not v.FBoEffect then
				stateSp = "es_wsx.png"
			end

			local stateSp = display.newSprite(res.gettex2("pic/panels/equipSuiteAct/" .. stateSp)):anchor(0, 0.5):pos(180, posY - 3):add2(bg, 100)

			stateSp.setRotation(stateSp, -30)

			if not v.FBoAct then
				posY = posY - 25
			else
				for propk, propv in ipairs(props) do
					local strs = string.split(propv, ":")

					if #strs == 2 then
						local propNameLabel = an.newLabel(strs[1] .. "：", 18, 0, {
							color = cc.c3b(240, 200, 150)
						}):addto(bg, 99):pos(10, posY):anchor(0, 0)

						an.newLabel(strs[2], 18, 0, {
							color = cc.c3b(220, 210, 190)
						}):addto(bg, 99):pos(propNameLabel.getw(propNameLabel) + 10, posY):anchor(0, 0)

						posY = posY - 25
					end
				end

				if suiteInfo.SpecShapeName and suiteInfo.SpecShapeName ~= "" then
					an.newLabel("[特效]" .. suiteInfo.SpecShapeName, 18, 0, {
						color = cc.c3b(240, 200, 150)
					}):addto(bg, 99):pos(10, posY):anchor(0, 0)

					posY = posY - 25
					local speProps = def.equipSuite.dumpPropertyStr(suiteInfo.SpePropStr, params.job or g_data.player.job)

					for propk, propv in ipairs(speProps) do
						local strs = string.split(propv, ":")

						if #strs == 2 then
							local propNameLabel = an.newLabel(strs[1] .. "：", 18, 0, {
								color = cc.c3b(240, 200, 150)
							}):addto(bg, 99):pos(10, posY):anchor(0, 0)

							an.newLabel(strs[2], 18, 0, {
								color = cc.c3b(220, 210, 190)
							}):addto(bg, 99):pos(propNameLabel.getw(propNameLabel) + 10, posY):anchor(0, 0)

							posY = posY - 25
						end
					end

					if v.FBoAct and v.FBoEffect and params.bSelf then
						local actBtnName = (v.FBoShowSpecShape and "关闭外显") or "开启外显"
						slot22 = an.newBtn(res.gettex2("pic/common/btn20.png"), function (btn)
							sound.playSound("103")

							local rsb = DefaultClientMessage(CM_ESSpecShapeOpenClose)
							rsb.FESType = v.FESType
							rsb.FESLv = v.FESLv

							MirTcpClient:getInstance():postRsb(rsb)

							return 
						end, {
							pressImage = res.gettex2("pic/common/btn21.png"),
							label = {
								actBtnName,
								16,
								0,
								{
									color = def.colors.Cf0c896
								}
							}
						}).add2(slot22, bg, 99):anchor(0.5, 0.5):pos(bg.getw(bg)/2, posY)
					end
				end
			end
		end

		local rect = cc.rect(params.minx or 0, params.miny or 0, params.maxx or display.width, params.maxy or display.height)
		local p = scenePos

		if p.x < rect.x then
			p.x = rect.x
		end

		if rect.width < p.x + w then
			p.x = p.x - w
		end

		if params.showType == "up" then
			if rect.height < p.y + h then
				p.y = rect.height - h
			end

			if p.y < rect.y then
				p.y = p.y
			end

			bg.pos(bg, p.x, p.y + h)
		else
			if rect.height < p.y then
				p.y = rect.height
			end

			if p.y - h < rect.y then
				p.y = p.y + h

				if rect.height < p.y then
					p.y = rect.height
				end
			end

			bg.pos(bg, p.x, p.y)
		end

		return layer
	end,
	close = function ()
		if info.layer then
			g_data.player.showTips = false

			info.layer:runs({
				cc.DelayTime:create(0.01),
				cc.RemoveSelf:create(true)
			})

			info.layer = nil
		end

		return 
	end,
	clear = function ()
		info.layer = nil

		return 
	end
}

return info
