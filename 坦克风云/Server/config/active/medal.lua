local medal ={
    multiSelectType = true,
    [1]={
        sortid=231,
        type=1,
        --折扣
        discount=0.8,
        --打折道具
        discountItem='p1',
        serverreward={
            --（upStep:涨价的步长，每兑换这个次数将涨价。upCount：涨价的价格，即每upStep次后价格增加upCount次。upLimit：涨价次数限制，即涨价这个次数后价格不再增长。changeLimit：兑换次数限制，即兑换这些次数后将不能继续兑换，此时已兑换的数量等于changeLimit*gets(num).
            --兑换列表（第N次兑换需求数量=道具1 * min(upLimit * upCount1 + num1 ，int（N/upStep) * upCount1 + num1) + 道具2 * min(upLimit * upCount2 + num2 ，int（N/upStep) * upCount2 + num2)）
            changeList={
                {serverreward={props_p19=10},gets={props_p3302=1},upStep=2,upCount={props_p19=10},upLimit=23,changeLimit=50},
                {serverreward={props_p19=8,userinfo_gems=10},gets={props_p3302=1},upStep=5,upCount={props_p19=8,userinfo_gems=10},upLimit=19,changeLimit=200},
            },
        },
        rewardTb={
            --（upStep:涨价的步长，每兑换这个次数将涨价。upCount：涨价的价格，即每upStep次后价格增加upCount次。upLimit：涨价次数限制，即涨价这个次数后价格不再增长。changeLimit：兑换次数限制，即兑换这些次数后将不能继续兑换，此时已兑换的数量等于changeLimit*gets(num).
            --兑换列表（第N次兑换需求数量=道具1 * min(upLimit * upCount1 + num1 ，int（N/upStep) * upCount1 + num1) + 道具2 * min(upLimit * upCount2 + num2 ，int（N/upStep) * upCount2 + num2)）
            changeList={
                {reward={p={{p19=10,index=1}}},gets={p={{p3302=1,index=1}}},upStep=2,upCount={10},upLimit=23,changeLimit=50},
                {reward={p={{p19=8,index=1}},u={{gems=10,index=2}}},gets={p={{p3302=1,index=1}}},upStep=5,upCount={8,10},upLimit=19,changeLimit=200},
            },
        },
    },
}

return medal 
