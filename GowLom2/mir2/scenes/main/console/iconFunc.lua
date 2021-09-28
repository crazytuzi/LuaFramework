local iconFunc = {
	getFilenames = function (self, config, data, useFromScene)
		local ret = {}

		if config.class == "btnMove" then
			if config.btntype == "normal" then
				if useFromScene or config.key == "btnFlyShoe" then
					if config.key == "btnChat" then
						ret.bg = "pic/console/btn_chat.png"
					elseif config.key == "btnHide" then
						ret.bg = "pic/console/btn_hide.png"
					elseif config.key == "btnHelper" then
						ret.bg = "pic/console/iconbg6.png"
						ret.sprite = "pic/console/widget-icons/btnHelper.png"
						ret.select = "pic/console/iconbg6s.png"
					elseif config.key == "btnGroup" then
						ret.bg = "pic/console/iconbg6.png"
						ret.sprite = "pic/console/widget-icons/btnGroup.png"
						ret.select = "pic/console/iconbg6s.png"
					elseif config.key == "btnAutoRat" then
						ret.bg = "pic/console/iconbg6.png"
						ret.sprite = "pic/console/widget-icons/btnAutoRat.png"
						ret.select = "pic/console/iconbg6s.png"
					elseif config.key == "btnAutoRat2" then
						ret.bg = "pic/console/iconbg2s.png"
						ret.sprite = "pic/console/widget-icons/btnAutoRat2.png"
						ret.select = "pic/console/iconbg10s.png"
					elseif config.key == "btnPet" then
						ret.bg = "pic/console/iconbg6.png"
						ret.sprite = "pic/console/widget-icons/btnPet.png"
						ret.select = "pic/console/iconbg6s.png"
					elseif config.key == "btnPet2" then
						ret.bg = "pic/console/iconbg6.png"

						if g_data.player.petInfo.state == 0 then
							ret.sprite = "pic/console/widget-icons/btnPet2.png"
						else
							ret.sprite = "pic/console/widget-icons/btnPet1.png"
						end

						ret.select = "pic/console/iconbg6s.png"
					elseif config.key == "btnHorse" then
						ret.bg = "pic/console/iconbg6.png"

						if g_data.player.horseInfo.state == 0 then
							ret.sprite = "pic/console/widget-icons/btnHorse.png"
						else
							ret.sprite = "pic/console/widget-icons/btnHorse1.png"
						end

						ret.select = "pic/console/iconbg6s.png"
					elseif config.key == "btnFlyShoe" then
						ret.bg = "pic/console/iconbg6.png"
						ret.sprite = "pic/console/widget-icons/btnFlyShoe.png"
						ret.select = "pic/console/iconbg6s.png"
						ret.text = "pic/console/prop-texts/btnFlyShoe.png"
					elseif config.key == "btnFlag" then
						print("config.key == ")

						ret.bg = "pic/console/iconbg6.png"

						if g_data.player.flagInfo.state == 0 then
							ret.sprite = "pic/console/widget-icons/btnFlag.png"
						else
							ret.sprite = "pic/console/widget-icons/btnFlag2.png"
						end

						ret.select = "pic/console/iconbg6s.png"
					elseif config.key == "btnHostility" then
						ret.bg = "pic/console/iconbg6.png"
						ret.sprite = "pic/console/widget-icons/btnHostility.png"
						ret.select = "pic/console/iconbg6s.png"
					elseif g_data.login:isChangeSkinCheckServer() then
						local chk_respath = g_data.login:getChkResPath()
						ret.bg = chk_respath .. "iconbg1.png"
						ret.sprite = chk_respath .. config.key .. ".png"
					else
						print(config.key)
						print("Unknown btn key!")
					end
				else
					ret.bg = "pic/console/iconbg1.png"
					ret.sprite = "pic/console/widget-icons/" .. config.key .. ".png"
				end
			elseif config.btntype == "base" then
				ret.bg = "pic/console/iconbg6.png"
				ret.sprite = "pic/console/skill_base-icons/" .. config.btnid .. ".png"
				ret.select = "pic/console/iconbg6s.png"
				ret.text = "pic/console/prop-texts/" .. config.btnid .. ".png"
			elseif config.btntype == "setting" then
				ret.bg = "pic/console/iconbg10.png"
				ret.sprite = "pic/console/setting-icons/" .. config.btnid .. ".png"
				ret.select = "pic/console/iconbg10s.png"
			elseif config.btntype == "skill" then
				ret.bg = "pic/console/iconbg6.png"
				ret.sprite = "pic/console/skill-icons/" .. data.magicId .. ".png"
				ret.select = "pic/console/iconbg6s.png"
			elseif config.btntype == "panel" then
				ret.bg = "pic/console/iconbg7.png"
				ret.sprite = "pic/console/panel-icons/" .. config.btnid .. ".png"
			elseif config.btntype == "prop" then
				ret.bg = "pic/console/iconbg9.png"
				ret.sprite = "pic/console/prop-icons/" .. config.btnid .. ".png"
				ret.text = "pic/console/prop-texts/" .. config.btnid .. ".png"
			elseif config.btntype == "cmd" then
				ret.bg = "pic/console/iconbg3.png"
				ret.sprite = "pic/console/cmd-icons/" .. config.btnid .. ".png"
			elseif config.btntype == "hero" then
				ret.bg = "pic/console/iconbg5.png"
				ret.sprite = "pic/console/hero-icons/" .. config.btnid .. ".png"
				ret.select = "pic/console/iconbg5s.png"
			elseif config.btntype == "custom" then
				ret.bg = "pic/console/custom.png"
			end
		else
			ret.bg = "pic/console/iconbg1.png"
			ret.sprite = "pic/console/widget-icons/" .. config.key .. ".png"
		end

		return ret
	end
}

return iconFunc
