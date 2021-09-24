local alientask ={
    multiSelectType = true,
    [1]={
        sortid=223,
        type=1,
        serverreward ={
            --完成任务链额外赠送
            taskExtra={
                {100},
                {2,2,2,2,2,2,2,2,5,5,5},
                {{"aweapon_af13",1},{"aweapon_af14",1},{"aweapon_af15",1},{"aweapon_af16",1},{"aweapon_af7",1},{"aweapon_af8",1},{"aweapon_af9",1},{"aweapon_af10",1},{"aweapon_ap1",10},{"aweapon_ap2",10},{"aweapon_ap3",10}},
            },
            --任务（标识，参数，奖励）
            taskList={
                --完成护送{1}次
                y1={
                    {{1},index=1,next=2,serverreward={{"props_p4021",3}}},
                    {{3},index=2,next=3,serverreward={{"aweapon_ap2",5},{"aweapon_ap3",5}}},
                    {{5},index=3,next=nil,serverreward={{"props_p4022",2}}},
                },
                --完成抢夺{1}次
                y2={
                    {{2},index=4,next=2,serverreward={{"props_p4021",3}}},
                    {{4},index=5,next=3,serverreward={{"aweapon_ap1",5},{"aweapon_ap4",5}}},
                    {{6},index=6,next=nil,serverreward={{"props_p4022",2}}},
                },
                --完成探索{1}次
                y3={
                    {{3},index=7,next=2,serverreward={{"aweapon_exp",200}}},
                    {{6},index=8,next=3,serverreward={{"aweapon_ap2",5},{"aweapon_ap1",5}}},
                    {{10},index=9,next=nil,serverreward={{"props_p4022",2}}},
                },
                --护送{1}色船{2}次
                y4={
                    {{1,1},index=10,next=2,serverreward={{"props_p4021",3}}},
                    {{2,1},index=11,next=3,serverreward={{"aweapon_ap3",5},{"aweapon_ap2",5}}},
                    {{3,1},index=12,next=nil,serverreward={{"props_p4022",2}}},
                },
                --抢夺{1}色船{2}次
                y5={
                    {{3,1},index=13,next=2,serverreward={{"aweapon_exp",200}}},
                    {{3,2},index=14,next=3,serverreward={{"aweapon_ap2",5},{"aweapon_ap4",5}}},
                    {{3,3},index=15,next=nil,serverreward={{"aweapon_ap5",5},{"aweapon_ap3",5},{"aweapon_ap1",5}}},
                },
            },
        },
    },
}

return alientask 
