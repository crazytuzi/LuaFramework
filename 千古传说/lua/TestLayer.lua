local t = {
	components = {
		{
			classname = "TFPanel", 
			components = {
				{
					classname = "TFImage",
					texture = "ui/createplayer/create_bg.png",
					objectname = "bg",
					x = 480,
					y = 320
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/xzwj_qhzt_btn.png",
					objectname = "btn_close",
					text = "关闭",
					x = 800,
					y = 554
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/xzwj_qhzt_btn.png",
					objectname = "btn_unequip",
					text = "卸下",
					x = 560,
					y = 554
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/xzwj_qhzt_btn.png",
					objectname = "btn_equip",
					text = "装备",
					x = 440,
					y = 554
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/xzwj_qhzt_btn.png",
					objectname = "btn_lost",
					text = "删除",
					x = 320,
					y = 554
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/xzwj_qhzt_btn.png",
					objectname = "btn_add",
					text = "新增",
					x = 200,
					y = 554	
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/xzwj_qhzt_btn.png",
					objectname = "btn_addRole",
					text = "新增队友",
					x = 680,
					y = 554	
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/xzwj_qhzt_btn.png",
					objectname = "dazaoBtn",
					text = "装备打造",
					x = 720,
					y = 350	
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/xzwj_qhzt_btn.png",
					objectname = "pataBtn",
					text = "无量山",
					x = 720,
					y = 250	
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/xzwj_qhzt_btn.png",
					objectname = "payBtn",
					text = "充值",
					x = 720,
					y = 50	
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/xzwj_qhzt_btn.png",
					objectname = "settingBtn",
					text = "系统设置",
					x = 720,
					y = 100	
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/xzwj_qhzt_btn.png",
					objectname = "bangpaiBtn",
					text = "帮派",
					x = 720,
					y = 150	
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/xzwj_qhzt_btn.png",
					objectname = "fightBtn",
					text = "战斗",
					x = 720,
					y = 400	
				},
				{
					classname = "TFTextField",
					objectname = "txt_id",
					placeHolder = "请输入id",
					touchEnabled = true, 
					align = "left",
					maxLength = 16,
					width = 436,
					height = 58,
					x = 395,
					y = 440,
				},
				{
					classname = "TFTextField",
					objectname = "txt_num",
					placeHolder = "请输入num",
					touchEnabled = true, 
					align = "left",
					maxLength = 16,
					width = 436,
					height = 58,
					x = 395,
					y = 405,
				},
				{
					classname = "TFTextButton",
					texture = "ui_new/item/bzt_sj_btn.png",
					objectname = "btn_click",
					text = "发送",
					x = 444,
					y = 163,
				},
			}
		},
	}
}

return t