local dailyNews={
    --index:头条优先级  每日将统计的index（最大！！）的设置为今日头条
    --type:1：军团  2：个人
    --condition1:满足统计条件的最小值（对应判定条件描述中的X），没有condition1，则表示统计值无限制
    --condition2:{a,b},统计值满足a,则将头条优先值提升b，没有condition2,则表示无需提升优先级，出现提升后，优先级相同的情况，则根据原排序再进行一次排序
    --例：condition2={10,20}  A事件原排序为15，B事件原排序为35，C事件排序为25，原排序为：ACB
    --现在A的统计值>=10，则将A的排序15增加20变为35，此时A、B事件排序相同，但根据原排序，A还是会在B后面  所以现在排序是CAB
    dailyList={
        d1={name="daily_news_name1",des="daily_news_des1",pic="daily_new_pic7.jpg",index=11,type=2,condition1=5,condition2={50,20}},
        d2={name="daily_news_name2",des="daily_news_des2",pic="daily_new_pic1.jpg",index=22,type=2,condition1=5,condition2={30,20}},
        d3={name="daily_news_name3",des="daily_news_des3",pic="daily_new_pic7.jpg",index=12,type=2,condition1=5,condition2={50,20}},
        d4={name="daily_news_name4",des="daily_news_des4",pic="daily_new_pic7.jpg",index=13,type=2,condition1=3,condition2={10,20}},
        d5={name="daily_news_name5",des="daily_news_des5",pic="daily_new_pic1.jpg",index=23,type=2,condition1=5,condition2={30,20}},
        d6={name="daily_news_name6",des="daily_news_des6",pic="daily_new_pic7.jpg",index=14,type=2,condition1=10,condition2={100,20}},
        d7={name="daily_news_name7",des="daily_news_des7",pic="daily_new_pic1.jpg",index=21,type=2,condition1=5,condition2={30,20}},
        d9={name="daily_news_name9",des="daily_news_des9",pic="daily_new_pic7.jpg",index=18,type=2,condition1=200,condition2={3000,20}},
        d10={name="daily_news_name10",des="daily_news_des10",pic="daily_new_pic7.jpg",index=20,type=2,condition1=200,condition2={3000,20}},
        d11={name="daily_news_name11",des="daily_news_des11",pic="daily_new_pic8.jpg",index=16,type=2,condition1=10,condition2={50,20}},
        d12={name="daily_news_name12",des="daily_news_des12",pic="daily_new_pic8.jpg",index=15,type=2,condition1=10,condition2={50,20}},
        d13={name="daily_news_name13",des="daily_news_des13",pic="daily_new_pic9.jpg",index=17,type=1,condition1=5,condition2={50,20}},
        d14={name="daily_news_name14",des="daily_news_des14",pic="daily_new_pic3.jpg",index=1,type=2},
        d15={name="daily_news_name15",des="daily_news_des15",pic="daily_new_pic3.jpg",index=2,type=2},
        d16={name="daily_news_name16",des="daily_news_des16",pic="daily_new_pic3.jpg",index=3,type=2},
        d18={name="daily_news_name18",des="daily_news_des18",pic="daily_new_pic8.jpg",index=52,type=2},
        d19={name="daily_news_name19",des="daily_news_des19",pic="daily_new_pic4.jpg",index=54,type=1},
        d20={name="daily_news_name20",des="daily_news_des20",pic="daily_new_pic4.jpg",index=53,type=1},
        d21={name="daily_news_name21",des="daily_news_des21",pic="daily_new_pic2.jpg",index=61,type=2},
        d22={name="daily_news_name22",des="daily_news_des22",pic="daily_new_pic2.jpg",index=62,type=2},
        d24={name="daily_news_name24",des="daily_news_des24",pic="daily_new_pic5.jpg",index=63,type=1},
        d25={name="daily_news_name25",des="daily_news_des25",pic="daily_new_pic5.jpg",index=64,type=1},
    },
    
    --等级低于playerLv的玩家不统计
    playerLv=10,
    --超过X天未登录的玩家不会计入统计
    playerDay=20,
}
return dailyNews
