local setting = {
	base = {
		DelayShow = false,
		NPCShowName = true,
		firePeral = false,
		lockColor = true,
		defeatTip = true,
		showExpValue = 20000,
		singleRocker = true,
		showExpEnable = false,
		equipBarLvl = true,
		touchRun = true,
		showOutHP = true,
		guild = false,
		autoUnpack = true,
		soundEnable = true,
		showNameOnly = false,
		doubleRocker = false,
		heroShowName = true,
		hideCorpse = false,
		hiBlood = false,
		petShowName = true,
		monShowName = true,
		quickexit = false,
		heroShowTitle = true,
		levelShow = true
	},
	protected = {
		role = {
			hp = {
				lastTime = 0,
				space = 10000,
				uses = "随机传送卷",
				isPercent = false,
				value = 0,
				enable = false
			},
			mp = {
				lastTime = 0,
				space = 10000,
				uses = "随机传送卷",
				isPercent = false,
				value = 0,
				enable = false
			},
			jiu = {
				lastTime = 0,
				space = 500,
				isPercent = true,
				value = 10,
				enable = false
			},
			yaojiu = {
				lastTime = 0,
				space = 9000,
				isPercent = false,
				value = 10,
				enable = false
			}
		},
		hero = {
			hp = {
				lastTime = 0,
				space = 10000,
				uses = "随机传送卷",
				isPercent = false,
				value = 0,
				enable = false
			},
			mp = {
				lastTime = 0,
				space = 10000,
				uses = "随机传送卷",
				isPercent = false,
				value = 0,
				enable = false
			},
			jiu = {
				lastTime = 0,
				space = 500,
				isPercent = true,
				value = 10,
				enable = false
			},
			yaojiu = {
				lastTime = 0,
				space = 9000,
				isPercent = false,
				value = 10,
				enable = false
			},
			miss = {
				lastTime = 0,
				space = 9000,
				isPercent = false,
				value = 40,
				enable = true
			}
		}
	},
	drugs = {
		roleSetting = {
			withNumber = false,
			withPercent = true
		},
		heroSetting = {
			withNumber = false,
			withPercent = true
		},
		role = {
			percentDrug = {
				normalHP = {
					value = 0.75,
					space = 2000,
					isPercent = true,
					lastTime = 0,
					enable = true
				},
				normalMP = {
					value = 0.75,
					space = 2000,
					isPercent = true,
					lastTime = 0,
					enable = true
				},
				quickHP = {
					value = 0.5,
					space = 500,
					isPercent = true,
					lastTime = 0,
					enable = true
				},
				quickMP = {
					value = 0.25,
					space = 500,
					isPercent = true,
					lastTime = 0,
					enable = true
				}
			},
			numberDrug = {
				normalHP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				},
				normalMP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				},
				quickHP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				},
				quickMP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				}
			}
		},
		hero = {
			percentDrug = {
				normalHP = {
					value = 0.75,
					space = 500,
					isPercent = true,
					lastTime = 0,
					enable = true
				},
				normalMP = {
					value = 0.75,
					space = 500,
					isPercent = true,
					lastTime = 0,
					enable = true
				},
				quickHP = {
					value = 0.5,
					space = 500,
					isPercent = true,
					lastTime = 0,
					enable = true
				},
				quickMP = {
					value = 0.25,
					space = 500,
					isPercent = true,
					lastTime = 0,
					enable = true
				}
			},
			numberDrug = {
				normalHP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				},
				normalMP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				},
				quickHP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				},
				quickMP = {
					value = 10,
					space = 4000,
					lastTime = 0,
					enable = false
				}
			}
		}
	},
	autoUnpack = {
		newbee = {
			pack = "新手金创药包",
			name = "新手金创药",
			min = 0,
			enable = true
		},
		hpMid = {
			pack = "金创药（中）包",
			name = "金创药(中量)",
			min = 0,
			enable = true
		},
		hpSmall = {
			pack = "金创药(小)包",
			name = "金创药(小量)",
			min = 0,
			enable = true
		},
		hpMid = {
			pack = "金创药(中)包",
			name = "金创药(中量)",
			min = 0,
			enable = true
		},
		hpBig = {
			pack = "超级金创药",
			name = "强效金创药",
			min = 0,
			enable = true
		},
		hpMidz = {
			pack = "金创药中包(赠)",
			name = "金创药中量(赠)",
			min = 0,
			enable = true
		},
		hpBigz = {
			pack = "超级金创药(赠)",
			name = "强效金创药(赠)",
			min = 0,
			enable = true
		},
		mpSmall = {
			pack = "魔法药(小)包",
			name = "魔法药(小量)",
			min = 0,
			enable = true
		},
		mpMid = {
			pack = "魔法药(中)包",
			name = "魔法药(中量)",
			min = 0,
			enable = true
		},
		mpBig = {
			pack = "超级魔法药",
			name = "强效魔法药",
			min = 0,
			enable = true
		},
		mpMidz = {
			pack = "魔法药中包(赠)",
			name = "魔法药中量(赠)",
			min = 0,
			enable = true
		},
		mpBigz = {
			pack = "超级魔法药(赠)",
			name = "强效魔法药(赠)",
			min = 0,
			enable = true
		},
		quick1 = {
			pack = "太阳水包",
			name = "强效太阳水",
			min = 0,
			enable = true
		},
		quick2 = {
			pack = "万年雪霜包",
			name = "万年雪霜",
			min = 0,
			enable = true
		},
		quick3 = {
			pack = "疗伤药包",
			name = "疗伤药",
			min = 0,
			enable = true
		},
		quick4 = {
			pack = "疗伤药包(任务)",
			name = "疗伤药(任务)",
			min = 0,
			enable = true
		},
		reel1 = {
			pack = "随机传送卷包",
			name = "随机传送卷",
			min = 0,
			enable = true
		},
		reel2 = {
			pack = "地牢逃脱卷包",
			name = "地牢逃脱卷",
			min = 0,
			enable = true
		},
		reel3 = {
			pack = "回城卷包",
			name = "回城卷",
			min = 0,
			enable = true
		},
		reel4 = {
			pack = "行会回城卷包",
			name = "行会回城卷",
			min = 0,
			enable = true
		}
	},
	job = {
		autoDun = false,
		autoInvisible = false,
		autoZhanjiashu = false,
		autoSword = false,
		autoAllSpace = false,
		autoFire = false,
		autoSpace = false,
		autoDunHero = false,
		autoWide = true,
		autoSkill = {
			space = 10,
			enable = false
		}
	},
	autoPack = {
		recover = {
			pack = "疗伤药包",
			name = "疗伤药",
			idx = 348,
			enable = true
		},
		snow = {
			pack = "万年雪霜包",
			name = "万年雪霜",
			idx = 347,
			enable = true
		},
		sun = {
			pack = "太阳水包",
			name = "强效太阳水",
			idx = 346,
			enable = false
		}
	},
	autoRat = {
		noPickUpItem = false,
		autoBindDrug = false,
		pickUpRatting = true,
		autoPoison = false,
		ignoreCripple = true,
		autoSpaceMove = {
			space = 10,
			use = "随机传送卷",
			enable = false
		},
		autoRoar = {
			space = 10,
			cnt = 5,
			enable = false
		},
		atkMagic = {},
		areaMagic = {
			cnt = 5,
			enable = false
		},
		autoPet = {
			enable = false
		},
		autoCure = {
			percent = 70,
			enable = false
		},
		autoCurePet = {
			percent = 60,
			enable = false
		}
	},
	display = {
		showHeroOutHP = false,
		showMonOutHP = true,
		mapScale = 1.25
	},
	cpu = {
		speedMode = false,
		loadMons = false,
		normalFont = false
	},
	help = {
		count = 7,
		looked = 0
	},
	chat = {
		whisperLimit = 1,
		alwaysTranslate = false,
		opens = {
			组队 = true,
			战队 = true
		},
		autoLoadVoice = {
			enable = false
		},
		autoPlayVoice = {
			喊话 = false,
			行会 = false,
			私聊 = false,
			战队 = false,
			组队 = false,
			附近 = false
		}
	},
	item = {
		pickOnRatting = false,
		pickUp = false,
		showName = true,
		hindGood = false,
		filt = {}
	},
	other = {
		medalImpress = false,
		buyNotTip = false
	},
	initEnd = function ()
		sound.setEnable(setting.base.soundEnable)

		an.label.normal = setting.cpu.normalFont
		local filt = setting.item.filt

		if not filt.极品属性道具 then
			filt.极品属性道具 = {
				hintName = true,
				pickOnRatting = true,
				isGood = true,
				pickUp = true
			}
		end

		setmetatable(filt, {
			__index = _G.def.items.filt
		})

		return 
	end,
	getGoodAttItemSetting = function ()
		return setting.item.filt.极品属性道具
	end,
	resetItemFilt = function ()
		setting.item.filt = {}
		local filt = setting.item.filt

		if not filt.极品属性道具 then
			filt.极品属性道具 = {
				hintName = true,
				pickOnRatting = true,
				isGood = true,
				pickUp = true
			}
		end

		setmetatable(setting.item.filt, {
			__index = _G.def.items.filt
		})

		return 
	end
}
local default = clone(slot0)
setting.reset = function ()
	for k, v in pairs(default) do
		setting[k] = clone(v)
	end

	setting.initEnd()

	return 
end
setting.init = function (playerName)
	setting.reset()

	for k, v in pairs(setting) do
		local saved = cache.getSetting(playerName, k)

		if saved then
			for k2, v2 in pairs(saved) do
				v[k2] = v2
			end
		end
	end

	setting.initEnd()

	return 
end

return setting
