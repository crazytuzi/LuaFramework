
local DEF = TalkView.DEF

return
{
    template = {
        -- 例1：删除pick-btn-1、pick-btn-2，延时0.5秒，删除传入的第一个model-tag
        remove_pick_btn = -- 步骤名为:remove_pick_btn
        {{remove = {model = {"pick-btn-1", "pick-btn-2",},},},
            {load = {tmpl   = "fade_out", params = {"pic-3"}, },},},

        -- 例2: 渐隐删除
    fade_out ={
        {action = {tag  = "@1", sync = true,
                what = {fadeout = {time = 0.2,},},},},
        {remove = {model = {"@1",},},},},

        -- 例3: 渐隐退场
    move_fade_out = {
        {action = {tag = "@1",sync = true,
                what = {spawn = {{ fadeout = {time = 0.25,},},
                         {move = {time = 0.25,by   = cc.p(500, 0), },},},},},},
        {remove = {model = {"@1",},},},},


    scale_xs = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xs1 = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0,by   = cc.p(0, 0), },},
                {scale = {time = 0,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xl = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.7,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(255, 255, 255),},},},



--------------@@@@@@@@@@@@@@@

    talk = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(320, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talk1 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk0 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk2 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talkzm = {
        {model = { tag = "text-board1",type  = DEF.PIC,
                   file  = "jq_28.png",order = 51,
                   pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 0,},},},
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@1",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),time=2, },},
        {remove = { model = {"talk-tag", "text-board1",}, },},
        },


    move3 = {
        {model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
         order = 50,pos= cc.p(-140, 320),name = "@3",nameBg = "jq_27.png",
         namePos = cc.p(0.5, 0.45),},},
        {model = {tag  = "@4",type  = DEF.PIC,file  = "@5",scale = 0.7,rotation3D=cc.vec3(0,180,0),skew = true,
            order = 50,pos= cc.p(840, 320),name = "@6",nameBg = "jq_27.png",
            namePos = cc.p(0.5, 0.45),},},
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {load = {tmpl = "scale_xs1",params = {"@2"},},},
        {action = {tag  = "@1",sync = false,what = {spawn = {{move = {time = 0.3,to = cc.p(100, 320),},},},},},},
        {action = {tag  = "@4",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},},
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {delay = {time = 0.5,},},
        },

    move1 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
            order = 50,pos= cc.p(-140, 320),
            },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.25,to = cc.p(100, 320),},},},},},
        },
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    move2 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,rotation3D=cc.vec3(0,180,0),
            order = 50,pos= cc.p(DEF.WIDTH+140, 320),
           },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},
        },
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    out3= {
        {remove = { model = {"name-tag1", "name-tag2", }, },},
        {action = { tag  = "@1",sync = false,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {action = { tag  = "@2",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {remove = { model = {"@1", "@2", }, },},
        },

    out1 = {
            {remove = { model = {"name-tag1", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1",}, },},
        },

    out2 = {
            {remove = { model = {"name-tag2", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1", }, },},
        },

    loop_map_action = {
        {action = {tag  = "@1",sync = false,what = {loop = {sequence = {{move = {time = 6,by  = cc.p(0, -100),},},
            {move = { time = 18,by   = cc.p(0, 100),},},},},},},},
        },

    bq11 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },

    bq12 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+100, 255),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq21 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq22 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    shake = {
        {action = {tag  = "__scene__",
            --sync = true,
        what = {sequence = {
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            },},},},},

    -- zm1= {{
    --      model = {
    --         tag    = "@1",             type   = DEF.LABEL,
    --         pos    = cc.p("@3","@4"),  order  = 100,
    --         size   = 40,               text = "@2",
    --         color  = cc.c3b(255,255,255),parent = "@5",
    --         time   =1,
    --     },},
    -- },
    zm1= {
    {  model = { tag = "text-board1",type  = DEF.PIC,
        file  = "jq_27.png",order = 102,scale=3.6,opacity=200,
        pos   = cc.p(DEF.WIDTH / 2, 780),fadein = { time = 0.3,},},
    },
    {delay = {time = 0.3,},},
    {   model = {
            tag    = "zm-tag", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,810), order  = 105,
            size   = 28, text = "@1",maxWidth = 540,
            color  = cc.c3b(255,255,255),
            -- parent = "@5",
            time   =1,
        },},
    {delay = {time = 1.5,},},
    {remove = { model = {"zm-tag","text-board1", }, },},
    },


    zm= {
    {   model = {
            tag    = "@2", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,"@2"), order  = 105,
            size   = 25, text = "@1",
            maxWidth = 500,
            color  = cc.c3b(244, 217, 174),
            -- parent = "@5",
            time   =1.5,
        },},
    {delay = {time = 0.5,},},
    -- {remove = { model = {"zm-tag", }, },},
    },



    mod3111={
	     {remove = { model = {"texiao", }, },},
	{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),     order     = 100,
            file      = "@1",         animation = "animation",
            scale     = "@2",         loop      = false,
            endRlease = true,         parent = "@5",
        },},
    },


    modbj1={
    {
        model = {
            tag   = "@1",
            type  = DEF.PIC,
            scale = "@3",
            pos   = cc.p("@4","@5"),
            order = "@6",
            file  = "@2",
            parent= "@7",
            rotation3D=cc.vec3("@8","@9","@10"),
        },
    },},
    modbj2={
	{
        model = {
            tag       = "@1",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = "@6",
            file      = "@2",         animation = "animation",
            scale     = "@3",         loop      = true,
            endRlease = false,         parent = "@7",  speed = "@11", rotation3D=cc.vec3("@8","@9","@10"),
        },},
    },


    mod3={{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = 100,
            file      = "@1",         animation = "animation",
            scaleX     = "@2",        scaleY     = "@3",
            loop      = false,        speed  = 0.2,
            endRlease = true,         parent = "@6",
        },},
    },


    mod21={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,180,0),
        },},
    },
    mod22={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,0,0),
        },},
    },


    mod31={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod32={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod41={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod42={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod52={
    {action = {tag  = "@1", sync = false,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "zou",
            scale = "@5",   parent = "@6", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "@1",sync = false,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},
        {action = { tag  = "pugong1",sync = true,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},

    -- {delay={time=0},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },



    jpt={
        {action = { tag  = "@1",sync = "@6",what = {jump = {
                   time = "@2",to = cc.p("@3","@4"),height="@7",times="@5",},},},},
        },

    jp1={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=10,times="@5",},},},},
        },
    jpzby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=2,times="@5",},},},},
        },

    jptby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

     jptbytb={
        {action = { tag  = "@1",sync = false,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

    wp={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",      pos= cc.p("@3","@4"),},},
     },

    wps={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",   parent = "@6",   pos= cc.p("@3","@4"),},},
     },


    bz={
        {action = { tag  = "@1",sync = true,what = {bezier = {
                   time = "@2",to = cc.p("@3","@4"),control={cc.p("@5","@6"),cc.p("@7","@8"),},},},},},
        },

    qr1={--下浮
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {action = {tag  = "@1",sync = false,what = {fadein = {time = "@3",},},},},
        {action = {tag  = "@2",sync = false,what = {fadein = {time = "@3",},},},},
        {delay = {time = 2.5,},},
        },

    qr2={--缩放
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p(0, 0),},},
             {scale= {time = "@2",to = "@3",},},},},},},
        {delay = {time = 0.3,},},
    },




    qc1={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {delay = {time = 0.2,},},
        {action = {tag  = "@2",sync = false,what = {fadeout = {time = "@3",},},},},
        {delay = {time = "@3",},},
        {remove = { model = {"@1", }, },},
    },



    qc2={--平移
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p("@3","@4"),},},
             {scale= {time = "@2",to = 0,},},},},},},
        {delay = {time = 0.2,},},
        {remove = { model = {"@1", }, },},
    },








jtt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },

jtttb={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },



jt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 1.5,},},
    },

jttb={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},},



qg={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },

qgbz={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },









xbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 1480),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.8,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.12,to=4.5},},
                  {move = {time = 0.12,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.1,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.15,to=0},},
                  {move = {time = 0.15,by = cc.p(0, -200),},},},},
                  },},},},
         },


zjbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 400),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.9,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.1,to=1},},
                  {move = {time = 0.1,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.3,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.1,to=0},},
                  {move = {time = 0.1,by = cc.p(0, -100),},},},},
                  },},},},
                  },





    },



---------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


-------------------------

     {
        model = {
            tag   = "mapbj",
            type  = DEF.PIC,
            scale = 1.2,
            pos   = cc.p(320, 600),
            order = -100,
            file  = "bj.png",
        },
    },


    {
         load = {tmpl = "wp",
             params = {"clip_f","wd780.jpg","320","640","1"},},
    },


    {
        model = {
            type = DEF.CC,
            tag = "clip_1",
            parent = "clip_f",
            class = "Node",
            pos = cc.p(0, -300),
            -- scale =0.8,
        },
    },
    {
        model = {
            tag   = "map0",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(-1020, 100),
            order = -99,
            file  = "huangye.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },
    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(900, 100),
            order = -99,
            file  = "huangye.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },
    {
        model = {
            tag   = "map2",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(2820, 100),
            order = -99,
            file  = "huangye.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,180,0),
        },
    },






    {
        model = {tag   = "curtain-window",type  = DEF.WINDOW,
                 size  = cc.size(DEF.WIDTH, 0),order = 100,
                 pos   = cc.p(DEF.WIDTH / 2, DEF.HEIGHT * 0.5),},
    },

    {
        delay = {time = 0.1,},
    },

	{
        music = {file = "backgroundmusic4.mp3",},
    },


      {
          load = {tmpl = "zm",
              params = {TR("你私自放走小龙女的事被暴露，"),"900"},},
      },

      {
          load = {tmpl = "zm",
              params = {TR("你的美女师父非常生气。"),"850"},},
      },

      {
          load = {tmpl = "zm",
              params = {TR("你本想好好哄哄你的师父，"),"800"},},
      },

      {
          load = {tmpl = "zm",
              params = {TR("然而接下来发生的事，"),"750"},},
      },

      {
          load = {tmpl = "zm",
              params = {TR("却让一切变得无法挽回……"),"700"},},
      },


    -- {delay = {time = 0.5,},},





    --  {
    --      load = {tmpl = "zm",
    --          params = {TR("面对去而复返的杨过，"),"600"},},
    --  },
    --  {
    --      load = {tmpl = "zm",
    --          params = {TR("小龙女心中满是欢喜，"),"550"},},
    --  },
    --  {
    --      load = {tmpl = "zm",
    --          params = {TR("躺在杨过的怀中，"),"500"},},
    --  },
    --  {
    --      load = {tmpl = "zm",
    --          params = {TR("小龙女心中柔肠千结，"),"450"},},
    --  },
    --  {
    --      load = {tmpl = "zm",
    --          params = {TR("似有千般言语想要倾诉……"),"400"},},
    --  },


     {delay = {time = 2.1,},},

     {remove = { model = {"900", "850", "800","750", "700", }, },},

    -- {remove = { model = {"600", "550", "500", "450", "400",}, },},


    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(-400,0),    order     = 50,
            file = "hero_luwushuang",    animation = "zou",
            scale = 0.2,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,10),
        },},





     {
         load = {tmpl = "jtt",
             params = {"clip_1","0","0.8","-100","-280"},},
     },
    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },


----正式剧情

     -- {
     --     load = {tmpl = "jtt",
     --         params = {"clip_1","0.8","3","-2800","-1000"},},
     -- },






    -- {remove = { model = {"lwshuang", }, },},
    -- {   model = {
    --         tag  = "lwshuang",     type  = DEF.FIGURE,
    --         pos= cc.p(0,100),    order     = 50,
    --         file = "hero_luwushuang",    animation = "yun",
    --         scale = 0.2,   parent = "clip_1", speed = 0.6,
    --         loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
    --     },},

        {action = { tag  = "lwshuang",sync = true,what = {move = {
                   time = 1.2,by = cc.p(400,100),},},},},

    -- {remove = { model = {"lwshuang", }, },},
    -- {   model = {
    --         tag  = "lwshuang",     type  = DEF.FIGURE,
    --         pos= cc.p(0,100),    order     = 50,
    --         file = "hero_luwushuang",    animation = "zou",
    --         scale = 0.2,   parent = "clip_1", speed = 0.6,
    --         loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,10),
    --     },},

        {action = { tag  = "lwshuang",sync = true,what = {move = {
                   time = 1.2,by = cc.p(280,120),},},},},

    {remove = { model = {"lwshuang", }, },},
    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(280,220),    order     = 50,
            file = "hero_luwushuang",    animation = "yun",
            scale = 0.2,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
    -- {
    --     model = {
    --         tag   = "xue1",
    --         type  = DEF.PIC,
    --         scaleX = 0.4,scaleY = 0.5,
    --         pos   = cc.p(-220, 400),
    --         order = 100,
    --         file  = "xue1.png",
    --         parent= "lwshuang",
    --         rotation3D=cc.vec3(0,0,0),
    --     },
    -- },


    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },
     {
         load = {tmpl = "move1",
             params = {"lws","lws.png",TR("陆无双")},},
     },


    {
        model = {
            tag   = "xue3",
            type  = DEF.PIC,
            scaleX = 0.36,scaleY = 0.35,
            pos   = cc.p(437, 662),
            order = 100,
            file  = "xue1.png",
            parent= "lws", opacity=255,
            rotation3D=cc.vec3(0,0,0),
        },
    },

     {
         load = {tmpl = "talk1",
             params = {"lws",TR("不！我不能死在这个疯子手里！"),"5027.mp3"},},
     },
     {
         load = {tmpl = "talk2",
             params = {"lws",TR("就算要死，也要见到傻蛋，让他要——小——心——！"),"5028.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"lws"},},
    },

    {remove = { model = {"lwshuang", }, },},
    {   model = {
            tag  = "lwshuang",     type  = DEF.FIGURE,
            pos= cc.p(280,220),    order     = 50,
            file = "hero_luwushuang",    animation = "pose",
            scale = 0.2,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,20),
        },},

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.5","0.8","-450","-280"},},
     },


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "lwshuang",sync = false,what ={ spawn={{scale= {time = 0.8,to = 0.05,},},
    {bezier = {time = 0.4,to = cc.p(600,420),
                                 control={cc.p(280,220),cc.p(360,500),}
    },},},
    },},},

    {
       delay = {time = 0.4,},
    },

        {action = {tag = "lwshuang",sync = false,
                what = {spawn = {{ fadeout = {time = 0.8,},},
                         {move = {time = 0.4,by   = cc.p(200, 120), },},},},},},

    {
       delay = {time = 0.4,},
    },

    {remove = { model = {"lwshuang", }, },},

    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(0,0),    order     = 50,
            file = "hero_ouyangke",    animation = "daiji",
            scale = 0.2,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "oyke",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.2,},},
    {bezier = {time = 0.2,to = cc.p(360,100),
                                 control={cc.p(0,0),cc.p(150,400),}
    },},},
    },},},

    {
       delay = {time = 0.2,},
    },
     {
         load = {tmpl = "move1",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },

     {
         load = {tmpl = "talk1",
             params = {"oyk",TR("跑吧！跑吧！你中了我的化血神掌，越跑就越痛苦！"),"5029.mp3"},},
     },
     {
         load = {tmpl = "talk2",
             params = {"oyk",TR("就让我好好欣赏你的惨叫吧！你可千万不要让我失望呢！"),"5030.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"oyk"},},
    },
    -- {action = {tag  = "oyke",sync = false,what ={ spawn={{scale= {time = 0.8,to = 0.05,},},
    -- {bezier = {time = 0.4,to = cc.p(600,420),
    --                              control={cc.p(360,100),cc.p(360,500),}
    -- },},},
    -- },},},

    -- {
    --    delay = {time = 0.4,},
    -- },

    --     {action = {tag = "oyke",sync = false,
    --             what = {spawn = {{ fadeout = {time = 0.8,},},
    --                      {move = {time = 0.4,by   = cc.p(200, 120), },},},},},},

    -- {
    --    delay = {time = 0.4,},
    -- },

    -- {remove = { model = {"oyke", }, },},



    {   model = {
            tag  = "lbyi",     type  = DEF.FIGURE,
            pos= cc.p(1900,10),    order     = 45,
            file = "hero_nvzhu",    animation = "daiji",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.5, rotation3D=cc.vec3(0,180,0),
        },},


    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1700,0),    order     = 45,
            file = "_lead_",    animation = "daiji",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

     {
         load = {tmpl = "jtt",
             params = {"clip_1","1","0.8","-1400","-280"},},
     },

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1700,0),    order     = 45,
            file = "_lead_",    animation = "daiji",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},


    {
       delay = {time = 0.1,},
    },


     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("师父！是陆姑娘！好像有人追杀她，我们去救救她吧……"),"1254.mp3"},},
     },

     {
         load = {tmpl = "move2",
             params = {"lby","lby.png",TR("洛白衣")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("陆姑娘陆姑娘！？我不是说过了吗，找玉女心经才是最重要的事情！你还想违抗师命吗？"),"1255.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("师父，可是……陆姑娘她……"),"1256.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("我不认识什么陆姑娘，她的死活也与我无关！"),"1257.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"zj","lby"},},
    },





     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.3","0.7","-1200","-120"},},
     },

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1700,0),    order     = 45,
            file = "_run_",    animation = "zou",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.3, rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "zjue",sync = true,what = {move = {
                   time = 1,by = cc.p(-200,0),},},},},


    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1500,0),    order     = 45,
            file = "_lead_",    animation = "daiji",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.9, rotation3D=cc.vec3(0,0,0),
        },},

    {
       delay = {time = 0.2,},
    },


     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk1",
             params = {"zj",TR("师父！？……我早该知道，冰封的你，心已冷透，爱恨情仇，忠孝侠义，在你那冰冷的心中——早已烟消云散……"),"1258.mp3"},},
     },
     {
         load = {tmpl = "talk0",
             params = {"zj",TR("这个世界，我追求的——是忠肝义胆，是侠骨柔肠，可这些，对你而言甚至比不上一本冷冰冰的武功秘籍……"),"1259.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"zj",TR("从今以后，你便继续冷血无情的去收集哪些所谓的武功秘籍吧！我……我们就此恩断义绝，后会无期！"),"1260.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"zj"},},
    },

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1500,0),    order     = 45,
            file = "_lead_",    animation = "daiji",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.9, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.1,},
    },

    {remove = { model = {"zjue", }, },},

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(1500,0),    order     = 45,
            file = "_lead_",    animation = "pose",
            scale = 0.2,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.9, rotation3D=cc.vec3(0,180,0),
        },},


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "zjue",sync = true,what ={ spawn={{scale= {time = 0.4,to = 0.2,},},
    {bezier = {time = 0.4,to = cc.p(1100,200),
                                 control={cc.p(1500,0),cc.p(1200,200),}
    },},},
    },},},


     {
         load = {tmpl = "move2",
             params = {"lby","lby.png",TR("洛白衣")},},
     },


     {
         load = {tmpl = "talk",
             params = {"lby",TR("       "),"3"},},
     },




    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },

    {
	   delay = {time = 0.1,},
	},
}
