--血条的位置

_G.CUICardConfig = 
{
	width = 80;---血条宽跟高
	hight = 10;

	--npc的名称
	[999] = 
	{
		x = 0;
		y = 0.30;
		z = -4;--称号与名字的高度差
		_z = 0.42;--任务图片与名字的高度差
		__z = -0.07;
		_y = 0.10;
		__y = -0.0002;
		name_size = 0.2;  --名字大小
		name_textcolor = 0xFFe9cd6c;--名字颜色   0xFFA9CE9E  0xFFBFDF57
		name_edgeColor = 0xFF000000;--名字边框颜色   0xAF928E54   0x00BFDF57
		_name_textcolor = 0xFFffeb73;--名字颜色(鼠标指向时)
		_name_edgeColor = 0xFF000000;--名字边框颜色(鼠标指向时)
		
		-- npc名字的颜色
		npc_name_textcolor = 0xFF95e438;--名字颜色
		npc_name_edgecolor = 0xFF000000;--名字边框颜色
		npc_name_txtcolor_mouseover = 0xFFE9CD6C;--名字颜色(鼠标指向时)
		npc_name_edgecolor_mouseover = 0xFF000000;--名字边框颜色(鼠标指向时)
		npc_title_textcolor = 0xFFcfb66a;--称号颜色
		npc_title_edgecolor = 0xFF000000;--称号边框颜色
		npc_title_textcolor_mouseover = 0xFFE9CD6C;--称号颜色(鼠标指向时)
		npc_title_edgecolor_mouseover = 0xFF000000;--称号边框颜色(鼠标指向时)
		npc_say_textcolor = 0xFFFFDB00;--说话颜色
		npc_say_edgecolor = 0xFF000000;--说话边框颜色
		
		-- monster名字的颜色
		monster_name_txtcolor = 0xFFC90606;--名字颜色
		monster_name_edgecolor = 0xFF000000;--名字边框颜色
		monster_name_txtcolor_mouseover = 0xFFD8D8D8;--名字颜色(鼠标指向时)
		monster_name_edgecolor_mouseover = 0xFF000000;--名字边框颜色(鼠标指向时)
		monster_title_textcolor = 0xFFC757E3;--称号颜色
		monster_title_edgecolor = 0xFF000000;--称号边框颜色
		monster_title_textcolor_mouseover = 0xFFC757E3;--称号颜色(鼠标指向时)
		monster_title_edgecolor_mouseover = 0xFF000000;--称号边框颜色(鼠标指向时)
		monster_say_textcolor = 0xFFFFDB00;--说话颜色
		monster_say_edgecolor = 0xFF000000;--说话边框颜色
		monster_name_txtcolor_battle = 0xFFC90606;--名字颜色(战斗时)
		monster_name_edgecolor_battle = 0xFF000000;--名字边框颜色(战斗时)
		--monster同阵营怪物名字颜色
		monster_name_txtcolor_friend = 0xFF29CC00;--名字边框颜色(战斗时)
		monster_name_edgecolor_friend = 0xFF000000;--名字边框颜色(战斗时)

		title_size = 0.2;	--称号大小
		title_textcolor = 0xFFe9cd6c;--称号颜色  0xEFFFFF00
		title_edgeColor = 0xFF000000;--称号边框颜色   0x00BFDF57
		_title_textcolor = 0xFFffeb73;--称号颜色(鼠标指向时)
		_title_edgeColor = 0xFF000000;--称号边框颜色(鼠标指向时)
		------------------
		say_size = 0.105;--说话大小
		say_textcolor = 0xffffdb00;--说话颜色  0xEFFFFF00
		say_edgeColor = 0xFF000000;--说话边框颜色   0x00BFDF57
		--_say_textcolor = 0xFFffffff;--说话颜色(鼠标指向时)
		--_say_edgeColor = 0xff00ff00;--说话边框颜色(鼠标指向时)

		---- 战场旗帜名字颜色
		camp_EnemyColor = 0xffff0000; -- 敌方颜色
		camp_OurColor = 0xff29CC00; -- 我方颜色

		pet_name_textcolor = 0xFF7fff00;
		pet_name_edgecolor = 0xFF000000;
		petplayer_name_textcolor = 0xFFffa200;
		petplayer_name_edgecolor = 0xFF000000;
		petotherplayer_name_textcolor = 0xFF00fffc;
		petotherplayer_name_edgecolor = 0xFF000000;

		can_collect_textcolor = 0xFFe9cd6c; --可以采集的采集物
		can_collect_edgeColor = 0xFF000000;
		cannot_collect_textcolor = 0xffa0a0a0; --可以采集的采集物
		cannot_collect_edgeColor = 0xFF000000;
	};

	--掉落的名称
	[0] =
	{
		x = 0;
		y = 0;
		z = 5;	--名字高度
		edgeColor = 0xFF000000;--名字边框颜色
	};
	--怪物的血条相对于名字的位置
	[1] = 
	{
		x = 0;
		y = 0.10;
		z = 2;--血条与名字的高度差
		_y = -0.0002;--血条和底板的位置差
		---------------------------------------
		size = 0.085;  --怪物名字大小
		textcolor = 0xFFff0000;--怪物名字颜色
		edgeColor = 0xFF000000;--怪物名字边框颜色
		_textcolor = 0xFFff0000;--怪物名字颜色(鼠标指向时)
		_edgeColor = 0xFF000000;--怪物名字边框颜色(鼠标指向时)
	};

	--主角的名字颜色
	nameColor = {
		self_textcolor = 0xFFffa200;                --自己名字颜色/字体0xFF228B22
        other_textcolor = 0xFF00fffc;               --别人名字颜色/字体
		self_edgeColor = 0xFF000000;                --自己名字颜色/边框 0xFF000000
		other_edgeColor = 0xFF000000;               --别人名字颜色/边框
		
		selfGuild_textcolor = 0xFF00FF00;           --自己帮派名字颜色/字体0xFF228B22
        otherGuild_textcolor = 0xFF3EC3FF;          --别人帮派名字颜色/字体
		selfGuild_edgeColor = 0xFF000000;           --自己帮派名字颜色/边框 0xFF000000
		otherGuild_edgeColor = 0xFF000000;          --别人帮派名字颜色/边框
		
		self_readcolor = 0xFFb80000;                --自己PK的颜色
		self_graycolor = 0xFF000000;                --别人PK的颜色
		
		self_mgraycolor = 0xffa0a0a0;               --自己挑衅的颜色
		self_tgraycolor = 0xff000000;               --别人挑衅的颜色
		
		selfAlianceGuildId_textColor = 0xff57e9ab;  --同盟的颜色

		partner_textcolor = 0xFFffa200;				--配偶的颜色
		partner_edgeColor = 0xFF000000;				--配偶的颜色

		hunche_textcolor = 0xFFffa200; 				--结婚时用
		hunche_edgecolor = 0xFF000000; 				--结婚时用
		
	};

	--主角的血条和名字的高度差
	hpZ = 15;
	--主角的名字和帮派名字的高度差
	nameZ = 40;
	--主角的帮派名字和称号的高度差
	guildNameZ = 30;

	--人的血条和名字的位置  --未骑乘
	nameHeight = 
	{
		--萝莉
		[1] = 18,
        --男魔
        [2] = 23,
        --人族
        [3] = 21,
        --御姐
        [4] = 22,
    };
};
