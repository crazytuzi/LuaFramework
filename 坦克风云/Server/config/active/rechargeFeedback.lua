local rechargeFeedback ={ -- 充值大回馈
    multiSelectType=true,
    [1]={
        type=1,
        sortId=101,
        version=1,
		rechargeRewardRadio=0.2, --充值返利比例（小数时向下取整）
		rechargeCost={50,268,910,1950}, --充值返利档位
		money={6,30,98,198}, --充值金额
		--充值领奖
		serverreward={r={	props_p19=5,	props_p20=3,	props_p4=1,	props_p47=3,	}},
		reward={r={p={	{p19=5,index=1},	{p20=3,index=2},	{p4=1,index=3},	{p47=3,index=4},	}}},

    },

}
return rechargeFeedback
