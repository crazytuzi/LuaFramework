
--stepId=步骤ID ,clickRect=可点击区域,hasCloseBtn=是否有关闭按钮,hasPanle=是否有面板,panlePos=面板坐标,clickToNext=点击屏幕进入下一步？ arrowDirect=1:向下 2:向上 3:右上    delayTime 可以不配置，显示引导面板的延迟时间

newGuidCfg={
    {stepId=1,clickRect=CCRectMake(100+250,250,200,150),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,570),clickToNext=false,arrowDirect=1,arrowPos=ccp(205+250,535),delayTime=0.2,toStepId=2},
    {stepId=2,clickRect=CCRectMake(405,46,187,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(500,295),delayTime=1,toStepId=3},
    {stepId=3,clickRect=nil,hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),delayTime=0.2,toStepId=4},
    {stepId=4,clickRect=CCRectMake(100+250,250,200,150),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,570),clickToNext=false,arrowDirect=1,arrowPos=ccp(205+250,535),toStepId=5},
    {stepId=5,clickRect=CCRectMake(218,790,202,105),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,280),clickToNext=false,arrowDirect=2,arrowPos=ccp(320,640),toStepId=6},
    {stepId=6,clickRect=CCRectMake(15,650,600,150),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,250),clickToNext=false,arrowDirect=2,arrowPos=ccp(340,505),toStepId=7},
    {stepId=7,clickRect=CCRectMake(395,29,187,95),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(490,270),toStepId=8},
    {stepId=8,clickRect=nil,hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,300),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),delayTime=0.2,toStepId=9},
    {stepId=9,clickRect=CCRectMake(520,865,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,300),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,752),toStepId=10},
    {stepId=10,clickRect=CCRectMake(140,-3,130,150),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(223,295),toStepId=11},
    {stepId=11,clickRect=CCRectMake(30,650,210,220),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,120),clickToNext=false,arrowDirect=2,arrowPos=ccp(140,505),delayTime=0.2,toStepId=12},
    {stepId=12,clickRect=CCRectMake(45,635-160,150,122),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,260-160),clickToNext=false,arrowDirect=1,arrowPos=ccp(120,905-160),toStepId=13},

    {stepId=13,clickRect=CCRectMake(226,31,185,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(320,275),toStepId=14},
    {stepId=14,clickRect=CCRectMake(426,31,185,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(520,275),delayTime=0.2,toStepId=15},
    {stepId=15,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),toStepId=16},
    {stepId=16,clickRect=CCRectMake(219,183+60,200,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,460+100),clickToNext=false,arrowDirect=1,arrowPos=ccp(320,430+60),toStepId=19},
    {stepId=17,clickRect=CCRectMake(520,865,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,752),toStepId=18},
    {stepId=18,clickRect=CCRectMake(520,865,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,752),toStepId=19},
    
    {stepId=19,clickRect=CCRectMake(-5,-5,160,150),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(84,288),toStepId=20},
    {stepId=20,clickRect=CCRectMake(115,580,200,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,180),clickToNext=false,arrowDirect=1,arrowPos=ccp(216,825),toStepId=21},
    {stepId=21,clickRect=CCRectMake(20,650,600,170),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,200),clickToNext=false,arrowDirect=2,arrowPos=ccp(330,500),toStepId=22},
    {stepId=22,clickRect=CCRectMake(398,30,200,102),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(500,280),toStepId=23},
    {stepId=23,clickRect=CCRectMake(290,660,200,110),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,430),clickToNext=false,arrowDirect=2,arrowPos=ccp(390,510),toStepId=24},
    {stepId=24,clickRect=CCRectMake(20,480,600,170),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,100),clickToNext=false,arrowDirect=1,arrowPos=ccp(320,795),toStepId=25},
    {stepId=25,clickRect=CCRectMake(398,30,200,102),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(500,280),toStepId=26},
    {stepId=26,clickRect=CCRectMake(388,713,200,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,230),clickToNext=false,arrowDirect=2,arrowPos=ccp(488,562),toStepId=27},
    {stepId=27,clickRect=CCRectMake(20,330,600,170),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,600),clickToNext=false,arrowDirect=2,arrowPos=ccp(330,182),toStepId=28},
    {stepId=28,clickRect=CCRectMake(398,30,200,102),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(500,280),toStepId=30},
        {stepId=29,clickRect=nil,hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),toStepId=30},
    {stepId=30,clickRect=CCRectMake(310,375,330,250),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,630),clickToNext=false,arrowDirect=2,arrowPos=ccp(480,228),toStepId=31},
    {stepId=31,clickRect=CCRectMake(0,493,80,90),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,130),clickToNext=false,arrowDirect=4,arrowPos=ccp(140,540),toStepId=32},


    {stepId=32,clickRect=CCRectMake(464,631,150,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,180),clickToNext=false,arrowDirect=1,arrowPos=ccp(540,877),toStepId=33},
    {stepId=33,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),toStepId=34},
    {stepId=34,clickRect=CCRectMake(464,631,150,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,180),clickToNext=false,arrowDirect=1,arrowPos=ccp(540,877),toStepId=35},
    {stepId=35,clickRect=CCRectMake(520,865,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,300),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,752),toStepId=36},
    

        {stepId=36,clickRect=CCRectMake(-5,860,280,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,250),clickToNext=false,arrowDirect=2,arrowPos=ccp(150,713),delayTime=0.2,toStepId=38},
    {stepId=37,clickRect=CCRectMake(-5,860,370,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,250),clickToNext=false,arrowDirect=2,arrowPos=ccp(200,713),delayTime=0.2,toStepId=38},
    {stepId=38,clickRect=CCRectMake(495,190-40,110,110),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,450),clickToNext=false,arrowDirect=2,arrowPos=ccp(550,58-40),toStepId=39},
    {stepId=39,clickRect=CCRectMake(210,785,220,110),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=2,arrowPos=ccp(325,635),toStepId=40},
    {stepId=40,clickRect=CCRectMake(495,640,110,110),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,200),clickToNext=false,arrowDirect=2,arrowPos=ccp(550,493),toStepId=41},
    {stepId=41,clickRect=CCRectMake(520,865,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,300),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,752),toStepId=43},
    {stepId=42,clickRect=CCRectMake(520,865,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,300),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,752),toStepId=43},
    {stepId=43,clickRect=CCRectMake(0,814,640,60),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=false,arrowDirect=2,arrowPos=ccp(480,663),toStepId=44},
    {stepId=44,clickRect=CCRectMake(20,380,600,160),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,600),clickToNext=false,arrowDirect=2,arrowPos=ccp(332,230),toStepId=45},
    {stepId=45,clickRect=CCRectMake(429,296,180,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,470),clickToNext=false,arrowDirect=2,arrowPos=ccp(520,142),toStepId=48},
    {stepId=46,clickRect=CCRectMake(520,865,124,100),hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,300),clickToNext=false,arrowDirect=3,arrowPos=ccp(406,752),toStepId=48},
        {stepId=47,clickRect=nil,hasCloseBtn=true,hasPanle=true,panlePos=ccp(10,400),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),toStepId=48},
    {stepId=48,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,400),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),toStepId=55},
        
        {stepId=49,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,400),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),delayTime=0.2,toStepId=50},
        {stepId=50,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,400),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),showGirl=false,delayTime=0.2,toStepId=52},
        {stepId=51,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,400),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),showGirl=false,delayTime=0.2,toStepId=52},
        {stepId=52,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),delayTime=0.2,toStepId=53},
        {stepId=53,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,400),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),showGirl=false,delayTime=3,toStepId=55},
        {stepId=54,clickRect=nil,hasCloseBtn=false,hasPanle=true,panlePos=ccp(10,400),clickToNext=true,arrowDirect=1,arrowPos=ccp(100,100),showGirl=false,delayTime=0.2,toStepId=55},
        {stepId=55,clickRect=nil,hasCloseBtn=false,hasPanle=false,panlePos=ccp(10,400),clickToNext=false,arrowDirect=1,arrowPos=ccp(100,100),showGirl=false,delayTime=0.2,toStepId=49},
   
}