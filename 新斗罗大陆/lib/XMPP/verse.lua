package.preload['util.encodings']=(function(...)
local function e()
error("Function not implemented");
end
local t=require"mime";
module"encodings"
stringprep={};
base64={encode=t.b64,decode=e};
return _M;
end)
package.preload['util.hashes']=(function(...)
local e=require"util.sha1";
return{sha1=e.sha1};
end)
package.preload['util.sha1']=(function(...)
local m=string.len
local a=string.char
local g=string.byte
local k=string.sub
local c=math.floor
local t=require"bit"
local q=t.bnot
local e=t.band
local y=t.bor
local n=t.bxor
local o=t.lshift
local i=t.rshift
local l,d,s,h,r
local function p(e,t)
return o(e,t)+i(e,32-t)
end
local function u(i)
local t,o
local t=""
for n=1,8 do
o=e(i,15)
if(o<10)then
t=a(o+48)..t
else
t=a(o+87)..t
end
i=c(i/16)
end
return t
end
local function j(t)
local i,o
local n=""
i=m(t)*8
t=t..a(128)
o=56-e(m(t),63)
if(o<0)then
o=o+64
end
for e=1,o do
t=t..a(0)
end
for t=1,8 do
n=a(e(i,255))..n
i=c(i/256)
end
return t..n
end
local function b(f)
local u,t,o,i,w,c,m,v
local a,a
local a={}
while(f~="")do
for e=0,15 do
a[e]=0
for t=1,4 do
a[e]=a[e]*256+g(f,e*4+t)
end
end
for e=16,79 do
a[e]=p(n(n(a[e-3],a[e-8]),n(a[e-14],a[e-16])),1)
end
u=l
t=d
o=s
i=h
w=r
for s=0,79 do
if(s<20)then
c=y(e(t,o),e(q(t),i))
m=1518500249
elseif(s<40)then
c=n(n(t,o),i)
m=1859775393
elseif(s<60)then
c=y(y(e(t,o),e(t,i)),e(o,i))
m=2400959708
else
c=n(n(t,o),i)
m=3395469782
end
v=p(u,5)+c+w+m+a[s]
w=i
i=o
o=p(t,30)
t=u
u=v
end
l=e(l+u,4294967295)
d=e(d+t,4294967295)
s=e(s+o,4294967295)
h=e(h+i,4294967295)
r=e(r+w,4294967295)
f=k(f,65)
end
end
local function a(e,t)
e=j(e)
l=1732584193
d=4023233417
s=2562383102
h=271733878
r=3285377520
b(e)
local e=u(l)..u(d)..u(s)
..u(h)..u(r);
if t then
return e;
else
return(e:gsub("..",function(e)
return string.char(tonumber(e,16));
end));
end
end
_G.sha1={sha1=a};
return _G.sha1;
end)
package.preload['lib.adhoc']=(function(...)
local n,h=require"util.stanza",require"util.uuid";
local e="http://jabber.org/protocol/commands";
local i={}
local s={};
function _cmdtag(o,i,a,t)
local e=n.stanza("command",{xmlns=e,node=o.node,status=i});
if a then e.attr.sessionid=a;end
if t then e.attr.action=t;end
return e;
end
function s.new(t,e,o,a)
return{name=t,node=e,handler=o,cmdtag=_cmdtag,permission=(a or"user")};
end
function s.handle_cmd(a,s,o)
local e=o.tags[1].attr.sessionid or h.generate();
local t={};
t.to=o.attr.to;
t.from=o.attr.from;
t.action=o.tags[1].attr.action or"execute";
t.form=o.tags[1]:child_with_ns("jabber:x:data");
local t,h=a:handler(t,i[e]);
i[e]=h;
local o=n.reply(o);
if t.status=="completed"then
i[e]=nil;
cmdtag=a:cmdtag("completed",e);
elseif t.status=="canceled"then
i[e]=nil;
cmdtag=a:cmdtag("canceled",e);
elseif t.status=="error"then
i[e]=nil;
o=n.error_reply(o,t.error.type,t.error.condition,t.error.message);
s.send(o);
return true;
else
cmdtag=a:cmdtag("executing",e);
end
for t,e in pairs(t)do
if t=="info"then
cmdtag:tag("note",{type="info"}):text(e):up();
elseif t=="warn"then
cmdtag:tag("note",{type="warn"}):text(e):up();
elseif t=="error"then
cmdtag:tag("note",{type="error"}):text(e.message):up();
elseif t=="actions"then
local t=n.stanza("actions");
for o,e in ipairs(e)do
if(e=="prev")or(e=="next")or(e=="complete")then
t:tag(e):up();
else
module:log("error",'Command "'..a.name..
'" at node "'..a.node..'" provided an invalid action "'..e..'"');
end
end
cmdtag:add_child(t);
elseif t=="form"then
cmdtag:add_child((e.layout or e):form(e.values));
elseif t=="result"then
cmdtag:add_child((e.layout or e):form(e.values,"result"));
elseif t=="other"then
cmdtag:add_child(e);
end
end
o:add_child(cmdtag);
s.send(o);
return true;
end
return s;
end)
package.preload['util.rsm']=(function(...)
local s=require"util.stanza".stanza;
local a,o=tostring,tonumber;
local i=type;
local h=pairs;
local n='http://jabber.org/protocol/rsm';
local t={};
do
local e=t;
local function t(e)
return o((e:get_text()));
end
local function a(t)
return t:get_text();
end
e.after=a;
e.before=function(e)
local e=e:get_text();
return e==""or e;
end;
e.max=t;
e.index=t;
e.first=function(e)
return{index=o(e.attr.index);e:get_text()};
end;
e.last=a;
e.count=t;
end
local d=setmetatable({
first=function(t,e)
if i(e)=="table"then
t:tag("first",{index=e.index}):text(e[1]):up();
else
t:tag("first"):text(a(e)):up();
end
end;
before=function(t,e)
if e==true then
t:tag("before"):up();
else
t:tag("before"):text(a(e)):up();
end
end
},{
__index=function(e,t)
return function(e,o)
e:tag(t):text(a(o)):up();
end
end;
});
local function i(e)
local o={};
for a in e:childtags()do
local e=a.name;
local t=e and t[e];
if t then
o[e]=t(a);
end
end
return o;
end
local function r(a)
local e=s("set",{xmlns=n});
for a,o in h(a)do
if t[a]then
d[a](e,o);
end
end
return e;
end
local function t(e)
local e=e:get_child("set",n);
if e and#e.tags>0 then
return i(e);
end
end
return{parse=i,generate=r,get=t};
end)
package.preload['util.stanza']=(function(...)
local t=table.insert;
local s=table.remove;
local p=table.concat;
local r=string.format;
local u=string.match;
local c=tostring;
local w=setmetatable;
local n=pairs;
local o=ipairs;
local i=type;
local y=string.gsub;
local l=string.sub;
local m=string.find;
local e=os;
local f=not e.getenv("WINDIR");
local d,a;
if f then
local t,e=pcall(require,"util.termcolours");
if t then
d,a=e.getstyle,e.getstring;
else
f=nil;
end
end
local v="urn:ietf:params:xml:ns:xmpp-stanzas";
module"stanza"
stanza_mt={__type="stanza"};
stanza_mt.__index=stanza_mt;
local e=stanza_mt;
function stanza(a,t)
local t={name=a,attr=t or{},tags={}};
return w(t,e);
end
local h=stanza;
function e:query(e)
return self:tag("query",{xmlns=e});
end
function e:body(t,e)
return self:tag("body",e):text(t);
end
function e:tag(a,e)
local a=h(a,e);
local e=self.last_add;
if not e then e={};self.last_add=e;end
(e[#e]or self):add_direct_child(a);
t(e,a);
return self;
end
function e:text(t)
local e=self.last_add;
(e and e[#e]or self):add_direct_child(t);
return self;
end
function e:up()
local e=self.last_add;
if e then s(e);end
return self;
end
function e:reset()
self.last_add=nil;
return self;
end
function e:add_direct_child(e)
if i(e)=="table"then
t(self.tags,e);
end
t(self,e);
end
function e:add_child(t)
local e=self.last_add;
(e and e[#e]or self):add_direct_child(t);
return self;
end
function e:get_child(t,a)
for o,e in o(self.tags)do
if(not t or e.name==t)
and((not a and self.attr.xmlns==e.attr.xmlns)
or e.attr.xmlns==a)then
return e;
end
end
end
function e:get_child_text(e,t)
local e=self:get_child(e,t);
if e then
return e:get_text();
end
return nil;
end
function e:child_with_name(t)
for a,e in o(self.tags)do
if e.name==t then return e;end
end
end
function e:child_with_ns(t)
for a,e in o(self.tags)do
if e.attr.xmlns==t then return e;end
end
end
function e:children()
local e=0;
return function(t)
e=e+1
return t[e];
end,self,e;
end
function e:childtags(i,o)
local e=self.tags;
local t,a=1,#e;
return function()
for a=t,a do
local e=e[a];
if(not i or e.name==i)
and((not o and self.attr.xmlns==e.attr.xmlns)
or e.attr.xmlns==o)then
t=a+1;
return e;
end
end
end;
end
function e:maptags(i)
local o,e=self.tags,1;
local n,a=#self,#o;
local t=1;
while e<=a and a>0 do
if self[t]==o[e]then
local i=i(self[t]);
if i==nil then
s(self,t);
s(o,e);
n=n-1;
a=a-1;
t=t-1;
e=e-1;
else
self[t]=i;
o[e]=i;
end
e=e+1;
end
t=t+1;
end
return self;
end
function e:find(a)
local e=1;
local s=#a+1;
repeat
local o,t,i;
local n=l(a,e,e);
if n=="@"then
return self.attr[l(a,e+1)];
elseif n=="{"then
o,e=u(a,"^([^}]+)}()",e+1);
end
t,i,e=u(a,"^([^@/#]*)([/#]?)()",e);
t=t~=""and t or nil;
if e==s then
if i=="#"then
return self:get_child_text(t,o);
end
return self:get_child(t,o);
end
self=self:get_child(t,o);
until not self
end
local l
do
local e={["'"]="&apos;",["\""]="&quot;",["<"]="&lt;",[">"]="&gt;",["&"]="&amp;"};
function l(t)return(y(t,"['&<>\"]",e));end
_M.xml_escape=l;
end
local function y(a,e,h,o,r)
local i=0;
local s=a.name
t(e,"<"..s);
for a,n in n(a.attr)do
if m(a,"\1",1,true)then
local s,a=u(a,"^([^\1]*)\1?(.*)$");
i=i+1;
t(e," xmlns:ns"..i.."='"..o(s).."' ".."ns"..i..":"..a.."='"..o(n).."'");
elseif not(a=="xmlns"and n==r)then
t(e," "..a.."='"..o(n).."'");
end
end
local i=#a;
if i==0 then
t(e,"/>");
else
t(e,">");
for i=1,i do
local i=a[i];
if i.name then
h(i,e,h,o,a.attr.xmlns);
else
t(e,o(i));
end
end
t(e,"</"..s..">");
end
end
function e.__tostring(t)
local e={};
y(t,e,y,l,nil);
return p(e);
end
function e.top_tag(t)
local e="";
if t.attr then
for t,a in n(t.attr)do if i(t)=="string"then e=e..r(" %s='%s'",t,l(c(a)));end end
end
return r("<%s%s>",t.name,e);
end
function e.get_text(e)
if#e.tags==0 then
return p(e);
end
end
function e.get_error(a)
local i,e,t;
local a=a:get_child("error");
if not a then
return nil,nil,nil;
end
i=a.attr.type;
for o,a in o(a.tags)do
if a.attr.xmlns==v then
if not t and a.name=="text"then
t=a:get_text();
elseif not e then
e=a.name;
end
if e and t then
break;
end
end
end
return i,e or"undefined-condition",t;
end
do
local e=0;
function new_id()
e=e+1;
return"lx"..e;
end
end
function preserialize(e)
local a={name=e.name,attr=e.attr};
for o,e in o(e)do
if i(e)=="table"then
t(a,preserialize(e));
else
t(a,e);
end
end
return a;
end
function deserialize(a)
if a then
local s=a.attr;
for e=1,#s do s[e]=nil;end
local h={};
for e in n(s)do
if m(e,"|",1,true)and not m(e,"\1",1,true)then
local a,t=u(e,"^([^|]+)|(.+)$");
h[a.."\1"..t]=s[e];
s[e]=nil;
end
end
for e,t in n(h)do
s[e]=t;
end
w(a,e);
for t,e in o(a)do
if i(e)=="table"then
deserialize(e);
end
end
if not a.tags then
local e={};
for n,o in o(a)do
if i(o)=="table"then
t(e,o);
end
end
a.tags=e;
end
end
return a;
end
local function s(a)
local o,i={},{};
for e,t in n(a.attr)do o[e]=t;end
local o={name=a.name,attr=o,tags=i};
for e=1,#a do
local e=a[e];
if e.name then
e=s(e);
t(i,e);
end
t(o,e);
end
return w(o,e);
end
clone=s;
function message(e,t)
if not t then
return h("message",e);
else
return h("message",e):tag("body"):text(t):up();
end
end
function iq(e)
if e and not e.id then e.id=new_id();end
return h("iq",e or{id=new_id()});
end
function reply(e)
return h(e.name,e.attr and{to=e.attr.from,from=e.attr.to,id=e.attr.id,type=((e.name=="iq"and"result")or e.attr.type)});
end
do
local a={xmlns=v};
function error_reply(e,i,o,t)
local e=reply(e);
e.attr.type="error";
e:tag("error",{type=i})
:tag(o,a):up();
if(t)then e:tag("text",a):text(t):up();end
return e;
end
end
function presence(e)
return h("presence",e);
end
if f then
local u=d("yellow");
local s=d("red");
local h=d("red");
local t=d("magenta");
local s=" "..a(u,"%s")..a(t,"=")..a(s,"'%s'");
local d=a(t,"<")..a(h,"%s").."%s"..a(t,">");
local h=d.."%s"..a(t,"</")..a(h,"%s")..a(t,">");
function e.pretty_print(e)
local t="";
for a,e in o(e)do
if i(e)=="string"then
t=t..l(e);
else
t=t..e:pretty_print();
end
end
local a="";
if e.attr then
for e,t in n(e.attr)do if i(e)=="string"then a=a..r(s,e,c(t));end end
end
return r(h,e.name,a,t,e.name);
end
function e.pretty_top_tag(e)
local t="";
if e.attr then
for e,a in n(e.attr)do if i(e)=="string"then t=t..r(s,e,c(a));end end
end
return r(d,e.name,t);
end
else
e.pretty_print=e.__tostring;
e.pretty_top_tag=e.top_tag;
end
return _M;
end)
package.preload['util.timer']=(function(...)
local o=require"net.server";
local d=math.min
local c=math.huge
local h=require"socket".gettime;
local r=table.insert;
local l=pairs;
local u=type;
local s={};
local t={};
module"timer"
local e;
if not o.event then
function e(a,n)
local i=h();
a=a+i;
if a>=i then
r(t,{a,n});
else
local t=n(i);
if t and u(t)=="number"then
return e(t,n);
end
end
end
o._addtimer(function()
local o=h();
if#t>0 then
for a,e in l(t)do
r(s,e);
end
t={};
end
local t=c;
for h,a in l(s)do
local n,i=a[1],a[2];
if n<=o then
s[h]=nil;
local a=i(o);
if u(a)=="number"then
e(a,i);
t=d(t,a);
end
else
t=d(t,n-o);
end
end
return t;
end);
else
local t=o.event;
local a=o.event_base;
local o=(t.core and t.core.LEAVE)or-1;
function e(i,t)
local e;
e=a:addevent(nil,0,function()
local t=t(h());
if t then
return 0,t;
elseif e then
return o;
end
end
,i);
end
end
add_task=e;
return _M;
end)
package.preload['util.termcolours']=(function(...)
local i,n=table.concat,table.insert;
local t,a=string.char,string.format;
local r=tonumber;
local h=ipairs;
local s=io.write;
local e;
if os.getenv("WINDIR")then
e=require"util.windows";
end
local o=e and e.get_consolecolor and e.get_consolecolor();
module"termcolours"
local d={
reset=0;bright=1,dim=2,underscore=4,blink=5,reverse=7,hidden=8;
black=30;red=31;green=32;yellow=33;blue=34;magenta=35;cyan=36;white=37;
["black background"]=40;["red background"]=41;["green background"]=42;["yellow background"]=43;["blue background"]=44;["magenta background"]=45;["cyan background"]=46;["white background"]=47;
bold=1,dark=2,underline=4,underlined=4,normal=0;
}
local u={
["0"]=o,
["1"]=7+8,
["1;33"]=2+4+8,
["1;31"]=4+8
}
local l={
[1]="font-weight: bold",[2]="opacity: 0.5",[4]="text-decoration: underline",[8]="visibility: hidden",
[30]="color:black",[31]="color:red",[32]="color:green",[33]="color:#FFD700",
[34]="color:blue",[35]="color: magenta",[36]="color:cyan",[37]="color: white",
[40]="background-color:black",[41]="background-color:red",[42]="background-color:green",
[43]="background-color:yellow",[44]="background-color:blue",[45]="background-color: magenta",
[46]="background-color:cyan",[47]="background-color: white";
};
local c=t(27).."[%sm%s"..t(27).."[0m";
function getstring(t,e)
if t then
return a(c,t,e);
else
return e;
end
end
function getstyle(...)
local e,t={...},{};
for a,e in h(e)do
e=d[e];
if e then
n(t,e);
end
end
return i(t,";");
end
local a="0";
function setstyle(e)
e=e or"0";
if e~=a then
s("\27["..e.."m");
a=e;
end
end
if e then
function setstyle(t)
t=t or"0";
if t~=a then
e.set_consolecolor(u[t]or o);
a=t;
end
end
if not o then
function setstyle(e)end
end
end
local function a(t)
if t=="0"then return"</span>";end
local e={};
for t in t:gmatch("[^;]+")do
n(e,l[r(t)]);
end
return"</span><span style='"..i(e,";").."'>";
end
function tohtml(e)
return e:gsub("\027%[(.-)m",a);
end
return _M;
end)
package.preload['util.uuid']=(function(...)
local e=math.random;
local n=tostring;
local e=os.time;
local i=os.clock;
local a=require"util.hashes".sha1;
module"uuid"
local t=0;
local function o()
local e=e();
if t>=e then e=t+1;end
t=e;
return e;
end
local function e(e)
return a(e..i()..n({}),true);
end
local t=e(o());
local function a(a)
t=e(t..a);
end
local function e(e)
if#t<e then a(o());end
local a=t:sub(0,e);
t=t:sub(e+1);
return a;
end
local function t()
return("%x"):format(e(1):byte()%4+8);
end
function generate()
return e(8).."-"..e(4).."-4"..e(3).."-"..(t())..e(3).."-"..e(12);
end
seed=a;
return _M;
end)
package.preload['net.dns']=(function(...)
local s=require"socket";
local q=require"util.timer";
local e,b=pcall(require,"util.windows");
local z=(e and b)or os.getenv("WINDIR");
local l,_,p,a,i=
coroutine,io,math,string,table;
local m,n,o,f,r,y,k,j,t,e,x=
ipairs,next,pairs,print,setmetatable,tostring,assert,error,unpack,select,type;
local e={
get=function(t,...)
local a=e('#',...);
for a=1,a do
t=t[e(a,...)];
if t==nil then break;end
end
return t;
end;
set=function(t,...)
local i=e('#',...);
local h,o=e(i-1,...);
local a,s;
for i=1,i-2 do
local i=e(i,...)
local e=t[i]
if o==nil then
if e==nil then
return;
elseif n(e,n(e))then
a=nil;s=nil;
elseif a==nil then
a=t;s=i;
end
elseif e==nil then
e={};
t[i]=e;
end
t=e
end
if o==nil and a then
a[s]=nil;
else
t[h]=o;
return o;
end
end;
};
local d,u=e.get,e.set;
local E=15;
module('dns')
local t=_M;
local h=i.insert
local function c(e)
return(e-(e%256))/256;
end
local function w(e)
local t={};
for o,e in o(e)do
t[o]=e;
t[e]=e;
t[a.lower(e)]=e;
end
return t;
end
local function v(i)
local e={};
for o,i in o(i)do
local t=a.char(c(o),o%256);
e[o]=t;
e[i]=t;
e[a.lower(i)]=t;
end
return e;
end
t.types={
'A','NS','MD','MF','CNAME','SOA','MB','MG','MR','NULL','WKS',
'PTR','HINFO','MINFO','MX','TXT',
[28]='AAAA',[29]='LOC',[33]='SRV',
[252]='AXFR',[253]='MAILB',[254]='MAILA',[255]='*'};
t.classes={'IN','CS','CH','HS',[255]='*'};
t.type=w(t.types);
t.class=w(t.classes);
t.typecode=v(t.types);
t.classcode=v(t.classes);
local function g(e,i,o)
if a.byte(e,-1)~=46 then e=e..'.';end
e=a.lower(e);
return e,t.type[i or'A'],t.class[o or'IN'];
end
local function v(t,a,n)
a=a or s.gettime();
for o,e in m(t)do
if e.tod then
e.ttl=p.floor(e.tod-a);
if e.ttl<=0 then
t[e[e.type:lower()]]=nil;
i.remove(t,o);
return v(t,a,n);
end
elseif n=='soft'then
k(e.ttl==0);
t[e[e.type:lower()]]=nil;
i.remove(t,o);
end
end
end
local e={};
e.__index=e;
e.timeout=E;
local function k(e)
local e=e.type and e[e.type:lower()];
if x(e)~="string"then
return"<UNKNOWN RDATA TYPE>";
end
return e;
end
local w={
LOC=e.LOC_tostring;
MX=function(e)
return a.format('%2i %s',e.pref,e.mx);
end;
SRV=function(e)
local e=e.srv;
return a.format('%5d %5d %5d %s',e.priority,e.weight,e.port,e.target);
end;
};
local x={};
function x.__tostring(e)
local t=(w[e.type]or k)(e);
return a.format('%2s %-5s %6i %-28s %s',e.class,e.type,e.ttl,e.name,t);
end
local k={};
function k.__tostring(t)
local e={};
for a,t in m(t)do
h(e,y(t)..'\n');
end
return i.concat(e);
end
local w={};
function w.__tostring(e)
local a=s.gettime();
local t={};
for i,e in o(e)do
for i,e in o(e)do
for o,e in o(e)do
v(e,a);
h(t,y(e));
end
end
end
return i.concat(t);
end
function e:new()
local t={active={},cache={},unsorted={}};
r(t,e);
r(t.cache,w);
r(t.unsorted,{__mode='kv'});
return t;
end
function t.random(...)
p.randomseed(p.floor(1e4*s.gettime())%4294967296);
t.random=p.random;
return t.random(...);
end
local function E(e)
e=e or{};
e.id=e.id or t.random(0,65535);
e.rd=e.rd or 1;
e.tc=e.tc or 0;
e.aa=e.aa or 0;
e.opcode=e.opcode or 0;
e.qr=e.qr or 0;
e.rcode=e.rcode or 0;
e.z=e.z or 0;
e.ra=e.ra or 0;
e.qdcount=e.qdcount or 1;
e.ancount=e.ancount or 0;
e.nscount=e.nscount or 0;
e.arcount=e.arcount or 0;
local t=a.char(
c(e.id),e.id%256,
e.rd+2*e.tc+4*e.aa+8*e.opcode+128*e.qr,
e.rcode+16*e.z+128*e.ra,
c(e.qdcount),e.qdcount%256,
c(e.ancount),e.ancount%256,
c(e.nscount),e.nscount%256,
c(e.arcount),e.arcount%256
);
return t,e.id;
end
local function c(t)
local e={};
for t in a.gmatch(t,'[^.]+')do
h(e,a.char(a.len(t)));
h(e,t);
end
h(e,a.char(0));
return i.concat(e);
end
local function p(a,e,o)
a=c(a);
e=t.typecode[e or'a'];
o=t.classcode[o or'in'];
return a..e..o;
end
function e:byte(e)
e=e or 1;
local o=self.offset;
local t=o+e-1;
if t>#self.packet then
j(a.format('out of bounds: %i>%i',t,#self.packet));
end
self.offset=o+e;
return a.byte(self.packet,o,t);
end
function e:word()
local t,e=self:byte(2);
return 256*t+e;
end
function e:dword()
local t,e,o,a=self:byte(4);
return 16777216*t+65536*e+256*o+a;
end
function e:sub(e)
e=e or 1;
local t=a.sub(self.packet,self.offset,self.offset+e-1);
self.offset=self.offset+e;
return t;
end
function e:header(t)
local e=self:word();
if not self.active[e]and not t then return nil;end
local e={id=e};
local t,a=self:byte(2);
e.rd=t%2;
e.tc=t/2%2;
e.aa=t/4%2;
e.opcode=t/8%16;
e.qr=t/128;
e.rcode=a%16;
e.z=a/16%8;
e.ra=a/128;
e.qdcount=self:word();
e.ancount=self:word();
e.nscount=self:word();
e.arcount=self:word();
for a,t in o(e)do e[a]=t-t%1;end
return e;
end
function e:name()
local a,t=nil,0;
local e=self:byte();
local o={};
if e==0 then return"."end
while e>0 do
if e>=192 then
t=t+1;
if t>=20 then j('dns error: 20 pointers');end;
local e=((e-192)*256)+self:byte();
a=a or self.offset;
self.offset=e+1;
else
h(o,self:sub(e)..'.');
end
e=self:byte();
end
self.offset=a or self.offset;
return i.concat(o);
end
function e:question()
local e={};
e.name=self:name();
e.type=t.type[self:word()];
e.class=t.class[self:word()];
return e;
end
function e:A(o)
local e,t,i,n=self:byte(4);
o.a=a.format('%i.%i.%i.%i',e,t,i,n);
end
function e:AAAA(a)
local e={};
for t=1,a.rdlength,2 do
local a,t=self:byte(2);
i.insert(e,("%02x%02x"):format(a,t));
end
e=i.concat(e,":"):gsub("%f[%x]0+(%x)","%1");
local t={};
for e in e:gmatch(":[0:]+:")do
i.insert(t,e)
end
if#t==0 then
a.aaaa=e;
return
elseif#t>1 then
i.sort(t,function(e,t)return#e>#t end);
end
a.aaaa=e:gsub(t[1],"::",1):gsub("^0::","::"):gsub("::0$","::");
end
function e:CNAME(e)
e.cname=self:name();
end
function e:MX(e)
e.pref=self:word();
e.mx=self:name();
end
function e:LOC_nibble_power()
local e=self:byte();
return((e-(e%16))/16)*(10^(e%16));
end
function e:LOC(e)
e.version=self:byte();
if e.version==0 then
e.loc=e.loc or{};
e.loc.size=self:LOC_nibble_power();
e.loc.horiz_pre=self:LOC_nibble_power();
e.loc.vert_pre=self:LOC_nibble_power();
e.loc.latitude=self:dword();
e.loc.longitude=self:dword();
e.loc.altitude=self:dword();
end
end
local function c(e,i,t)
e=e-2147483648;
if e<0 then i=t;e=-e;end
local n,o,t;
t=e%6e4;
e=(e-t)/6e4;
o=e%60;
n=(e-o)/60;
return a.format('%3d %2d %2.3f %s',n,o,t/1e3,i);
end
function e.LOC_tostring(e)
local t={};
h(t,a.format(
'%s    %s    %.2fm %.2fm %.2fm %.2fm',
c(e.loc.latitude,'N','S'),
c(e.loc.longitude,'E','W'),
(e.loc.altitude-1e7)/100,
e.loc.size/100,
e.loc.horiz_pre/100,
e.loc.vert_pre/100
));
return i.concat(t);
end
function e:NS(e)
e.ns=self:name();
end
function e:SOA(e)
end
function e:SRV(e)
e.srv={};
e.srv.priority=self:word();
e.srv.weight=self:word();
e.srv.port=self:word();
e.srv.target=self:name();
end
function e:PTR(e)
e.ptr=self:name();
end
function e:TXT(e)
e.txt=self:sub(self:byte());
end
function e:rr()
local e={};
r(e,x);
e.name=self:name(self);
e.type=t.type[self:word()]or e.type;
e.class=t.class[self:word()]or e.class;
e.ttl=65536*self:word()+self:word();
e.rdlength=self:word();
if e.ttl<=0 then
e.tod=self.time+30;
else
e.tod=self.time+e.ttl;
end
local a=self.offset;
local t=self[t.type[e.type]];
if t then t(self,e);end
self.offset=a;
e.rdata=self:sub(e.rdlength);
return e;
end
function e:rrs(t)
local e={};
for t=1,t do h(e,self:rr());end
return e;
end
function e:decode(t,o)
self.packet,self.offset=t,1;
local t=self:header(o);
if not t then return nil;end
local t={header=t};
t.question={};
local i=self.offset;
for e=1,t.header.qdcount do
h(t.question,self:question());
end
t.question.raw=a.sub(self.packet,i,self.offset-1);
if not o then
if not self.active[t.header.id]or not self.active[t.header.id][t.question.raw]then
self.active[t.header.id]=nil;
return nil;
end
end
t.answer=self:rrs(t.header.ancount);
t.authority=self:rrs(t.header.nscount);
t.additional=self:rrs(t.header.arcount);
return t;
end
e.delays={1,3};
function e:addnameserver(e)
self.server=self.server or{};
h(self.server,e);
end
function e:setnameserver(e)
self.server={};
self:addnameserver(e);
end
function e:adddefaultnameservers()
if z then
if b and b.get_nameservers then
for t,e in m(b.get_nameservers())do
self:addnameserver(e);
end
end
if not self.server or#self.server==0 then
self:addnameserver("208.67.222.222");
self:addnameserver("208.67.220.220");
end
else
local e=_.open("/etc/resolv.conf");
if e then
for e in e:lines()do
e=e:gsub("#.*$","")
:match('^%s*nameserver%s+(.*)%s*$');
if e then
e:gsub("%f[%d.](%d+%.%d+%.%d+%.%d+)%f[^%d.]",function(e)
self:addnameserver(e)
end);
end
end
end
if not self.server or#self.server==0 then
self:addnameserver("127.0.0.1");
end
end
end
function e:getsocket(a)
self.socket=self.socket or{};
self.socketset=self.socketset or{};
local e=self.socket[a];
if e then return e;end
local o,t;
e,t=s.udp();
if e and self.socket_wrapper then e,t=self.socket_wrapper(e,self);end
if not e then
return nil,t;
end
e:settimeout(0);
self.socket[a]=e;
self.socketset[e]=a;
o,t=e:setsockname('*',0);
if not o then return self:servfail(e,t);end
o,t=e:setpeername(self.server[a],53);
if not o then return self:servfail(e,t);end
return e;
end
function e:voidsocket(e)
if self.socket[e]then
self.socketset[self.socket[e]]=nil;
self.socket[e]=nil;
elseif self.socketset[e]then
self.socket[self.socketset[e]]=nil;
self.socketset[e]=nil;
end
e:close();
end
function e:socket_wrapper_set(e)
self.socket_wrapper=e;
end
function e:closeall()
for t,e in m(self.socket)do
self.socket[t]=nil;
self.socketset[e]=nil;
e:close();
end
end
function e:remember(e,t)
local i,o,a=g(e.name,e.type,e.class);
if t~='*'then
t=o;
local t=d(self.cache,a,'*',i);
if t then h(t,e);end
end
self.cache=self.cache or r({},w);
local a=d(self.cache,a,t,i)or
u(self.cache,a,t,i,r({},k));
if not a[e[o:lower()]]then
a[e[o:lower()]]=true;
h(a,e);
end
if t=='MX'then self.unsorted[a]=true;end
end
local function h(e,t)
return(e.pref==t.pref)and(e.mx<t.mx)or(e.pref<t.pref);
end
function e:peek(a,t,o)
a,t,o=g(a,t,o);
local e=d(self.cache,o,t,a);
if not e then return nil;end
if v(e,s.gettime())and t=='*'or not n(e)then
u(self.cache,o,t,a,nil);
return nil;
end
if self.unsorted[e]then i.sort(e,h);end
return e;
end
function e:purge(e)
if e=='soft'then
self.time=s.gettime();
for t,e in o(self.cache or{})do
for t,e in o(e)do
for t,e in o(e)do
v(e,self.time,'soft')
end
end
end
else self.cache=r({},w);end
end
function e:query(e,a,t)
e,a,t=g(e,a,t)
local n=l.running();
local o=d(self.wanted,t,a,e);
if n and o then
u(self.wanted,t,a,e,n,true);
return true;
end
if not self.server then self:adddefaultnameservers();end
local h=p(e,a,t);
local o=self:peek(e,a,t);
if o then return o;end
local i,o=E();
local i={
packet=i..h,
server=self.best_server,
delay=1,
retry=s.gettime()+self.delays[1]
};
self.active[o]=self.active[o]or{};
self.active[o][h]=i;
if n then
u(self.wanted,t,a,e,n,true);
end
local o,h=self:getsocket(i.server)
if not o then
return nil,h;
end
o:send(i.packet)
if q and self.timeout then
local r=#self.server;
local s=1;
q.add_task(self.timeout,function()
if d(self.wanted,t,a,e,n)then
if s<r then
s=s+1;
self:servfail(o);
i.server=self.best_server;
o,h=self:getsocket(i.server);
if o then
o:send(i.packet);
return self.timeout;
end
end
self:cancel(t,a,e);
end
end)
end
return true;
end
function e:servfail(t,h)
local i=self.socketset[t]
t=self:voidsocket(t);
self.time=s.gettime();
for s,a in o(self.active)do
for o,e in o(a)do
if e.server==i then
e.server=e.server+1
if e.server>#self.server then
e.server=1;
end
e.retries=(e.retries or 0)+1;
if e.retries>=#self.server then
a[o]=nil;
else
t,h=self:getsocket(e.server);
if t then t:send(e.packet);end
end
end
end
if n(a)==nil then
self.active[s]=nil;
end
end
if i==self.best_server then
self.best_server=self.best_server+1;
if self.best_server>#self.server then
self.best_server=1;
end
end
return t,h;
end
function e:settimeout(e)
self.timeout=e;
end
function e:receive(t)
self.time=s.gettime();
t=t or self.socket;
local e;
for a,t in o(t)do
if self.socketset[t]then
local t=t:receive();
if t then
e=self:decode(t);
if e and self.active[e.header.id]
and self.active[e.header.id][e.question.raw]then
for a,t in o(e.answer)do
if t.name:sub(-#e.question[1].name,-1)==e.question[1].name then
self:remember(t,e.question[1].type)
end
end
local t=self.active[e.header.id];
t[e.question.raw]=nil;
if not n(t)then self.active[e.header.id]=nil;end
if not n(self.active)then self:closeall();end
local e=e.question[1];
local t=d(self.wanted,e.class,e.type,e.name);
if t then
for e in o(t)do
if l.status(e)=="suspended"then l.resume(e);end
end
u(self.wanted,e.class,e.type,e.name,nil);
end
end
end
end
end
return e;
end
function e:feed(a,t,e)
self.time=s.gettime();
local e=self:decode(t,e);
if e and self.active[e.header.id]
and self.active[e.header.id][e.question.raw]then
for a,t in o(e.answer)do
self:remember(t,e.question[1].type);
end
local t=self.active[e.header.id];
t[e.question.raw]=nil;
if not n(t)then self.active[e.header.id]=nil;end
if not n(self.active)then self:closeall();end
local e=e.question[1];
if e then
local t=d(self.wanted,e.class,e.type,e.name);
if t then
for e in o(t)do
if l.status(e)=="suspended"then l.resume(e);end
end
u(self.wanted,e.class,e.type,e.name,nil);
end
end
end
return e;
end
function e:cancel(a,i,t)
local e=d(self.wanted,a,i,t);
if e then
for e in o(e)do
if l.status(e)=="suspended"then l.resume(e);end
end
u(self.wanted,a,i,t,nil);
end
end
function e:pulse()
while self:receive()do end
if not n(self.active)then return nil;end
self.time=s.gettime();
for i,t in o(self.active)do
for a,e in o(t)do
if self.time>=e.retry then
e.server=e.server+1;
if e.server>#self.server then
e.server=1;
e.delay=e.delay+1;
end
if e.delay>#self.delays then
t[a]=nil;
if not n(t)then self.active[i]=nil;end
if not n(self.active)then return nil;end
else
local t=self.socket[e.server];
if t then t:send(e.packet);end
e.retry=self.time+self.delays[e.delay];
end
end
end
end
if n(self.active)then return true;end
return nil;
end
function e:lookup(t,a,e)
self:query(t,a,e)
while self:pulse()do
local e={}
for a,t in m(self.socket)do
e[a]=t
end
s.select(e,nil,4)
end
return self:peek(t,a,e);
end
function e:lookupex(o,t,e,a)
return self:peek(t,e,a)or self:query(t,e,a);
end
function e:tohostname(e)
return t.lookup(e:gsub("(%d+)%.(%d+)%.(%d+)%.(%d+)","%4.%3.%2.%1.in-addr.arpa."),"PTR");
end
local i={
qr={[0]='query','response'},
opcode={[0]='query','inverse query','server status request'},
aa={[0]='non-authoritative','authoritative'},
tc={[0]='complete','truncated'},
rd={[0]='recursion not desired','recursion desired'},
ra={[0]='recursion not available','recursion available'},
z={[0]='(reserved)'},
rcode={[0]='no error','format error','server failure','name error','not implemented'},
type=t.type,
class=t.class
};
local function s(t,e)
return(i[e]and i[e][t[e]])or'';
end
function e.print(t)
for o,e in o{'id','qr','opcode','aa','tc','rd','ra','z',
'rcode','qdcount','ancount','nscount','arcount'}do
f(a.format('%-30s','header.'..e),t.header[e],s(t.header,e));
end
for e,t in m(t.question)do
f(a.format('question[%i].name         ',e),t.name);
f(a.format('question[%i].type         ',e),t.type);
f(a.format('question[%i].class        ',e),t.class);
end
local r={name=1,type=1,class=1,ttl=1,rdlength=1,rdata=1};
local e;
for n,i in o({'answer','authority','additional'})do
for h,n in o(t[i])do
for o,t in o({'name','type','class','ttl','rdlength'})do
e=a.format('%s[%i].%s',i,h,t);
f(a.format('%-30s',e),n[t],s(n,t));
end
for t,o in o(n)do
if not r[t]then
e=a.format('%s[%i].%s',i,h,t);
f(a.format('%-30s  %s',y(e),y(o)));
end
end
end
end
end
function t.resolver()
local t={active={},cache={},unsorted={},wanted={},best_server=1};
r(t,e);
r(t.cache,w);
r(t.unsorted,{__mode='kv'});
return t;
end
local e=t.resolver();
t._resolver=e;
function t.lookup(...)
return e:lookup(...);
end
function t.tohostname(...)
return e:tohostname(...);
end
function t.purge(...)
return e:purge(...);
end
function t.peek(...)
return e:peek(...);
end
function t.query(...)
return e:query(...);
end
function t.feed(...)
return e:feed(...);
end
function t.cancel(...)
return e:cancel(...);
end
function t.settimeout(...)
return e:settimeout(...);
end
function t.cache()
return e.cache;
end
function t.socket_wrapper_set(...)
return e:socket_wrapper_set(...);
end
return t;
end)
package.preload['net.adns']=(function(...)
local u=require"net.server";
local a=require"net.dns";
local t=require"util.logger".init("adns");
local e,e=table.insert,table.remove;
local n,h,l=coroutine,tostring,pcall;
local function c(a,a,e,t)return(t-e)+1;end
module"adns"
function lookup(d,e,s,r)
return n.wrap(function(o)
if o then
t("debug","Records for %s already cached, using those...",e);
d(o);
return;
end
t("debug","Records for %s not in cache, sending query (%s)...",e,h(n.running()));
local i,o=a.query(e,s,r);
if i then
n.yield({r or"IN",s or"A",e,n.running()});
t("debug","Reply for %s (%s)",e,h(n.running()));
end
if i then
i,o=l(d,a.peek(e,s,r));
else
t("error","Error sending DNS query: %s",o);
i,o=l(d,nil,o);
end
if not i then
t("error","Error in DNS response handler: %s",h(o));
end
end)(a.peek(e,s,r));
end
function cancel(e,o,i)
t("warn","Cancelling DNS lookup for %s",h(e[3]));
a.cancel(e[1],e[2],e[3],e[4],o);
end
function new_async_socket(i,o)
local s="<unknown>";
local n={};
local e={};
local h;
function n.onincoming(o,t)
if t then
a.feed(e,t);
end
end
function n.ondisconnect(a,i)
if i then
t("warn","DNS socket for %s disconnected: %s",s,i);
local e=o.server;
if o.socketset[a]==o.best_server and o.best_server==#e then
t("error","Exhausted all %d configured DNS servers, next lookup will try %s again",#e,e[1]);
end
o:servfail(a);
end
end
e,h=u.wrapclient(i,"dns",53,n);
if not e then
return nil,h;
end
e.settimeout=function()end
e.setsockname=function(t,...)return i:setsockname(...);end
e.setpeername=function(a,...)s=(...);local t,o=i:setpeername(...);a:set_send(c);return t,o;end
e.connect=function(t,...)return i:connect(...)end
e.send=function(a,e)
t("debug","Sending DNS query to %s",s);
return i:send(e);
end
return e;
end
a.socket_wrapper_set(new_async_socket);
return _M;
end)
package.preload['net.server']=(function(...)
local l=function(e)
return _G[e]
end
local C,e=require("util.logger").init("socket"),table.concat;
local i=function(...)return C("debug",e{...});end
local U=function(...)return C("warn",e{...});end
local X=1
local D=l"type"
local L=l"pairs"
local Z=l"ipairs"
local y=l"tonumber"
local h=l"tostring"
local t=l"os"
local o=l"table"
local a=l"string"
local e=l"coroutine"
local Y=t.difftime
local P=math.min
local ee=math.huge
local pe=o.concat
local ye=a.sub
local fe=e.wrap
local we=e.yield
local N=l"ssl"
local v=l"socket"or require"socket"
local V=v.gettime
local me=(N and N.wrap)
local se=v.bind
local ce=v.sleep
local ue=v.select
local G
local Q
local ie
local K
local ne
local c
local ae
local te
local oe
local he
local re
local B
local r
local de
local R
local le
local p
local s
local H
local d
local n
local S
local b
local w
local m
local a
local o
local g
local W
local F
local E
local A
local j
local J
local u
local O
local I
local _
local T
local z
local M
local k
local q
local x
p={}
s={}
d={}
H={}
n={}
b={}
w={}
S={}
a=0
o=0
g=0
W=0
F=0
E=1
A=0
j=128
O=51e3*1024
I=25e3*1024
_=12e5
T=6e4
z=6*60*60
local e=package.config:sub(1,1)=="\\"
q=(e and math.huge)or v._SETSIZE or 1024
k=v._SETSIZE or 1024
x=30
he=function(w,t,f,l,v,m)
if t:getfd()>=q then
U("server.lua: Disallowed FD number: "..t:getfd())
t:close()
return nil,"fd-too-large"
end
local u=0
local y,e=w.onconnect,w.ondisconnect
local b=t.accept
local e={}
e.shutdown=function()end
e.ssl=function()
return m~=nil
end
e.sslctx=function()
return m
end
e.remove=function()
u=u-1
if e then
e.resume()
end
end
e.close=function()
t:close()
o=r(d,t,o)
a=r(s,t,a)
p[f..":"..l]=nil;
n[t]=nil
e=nil
t=nil
i"server.lua: closed server handler and removed sockets from list"
end
e.pause=function(o)
if not e.paused then
a=r(s,t,a)
if o then
n[t]=nil
t:close()
t=nil;
end
e.paused=true;
end
end
e.resume=function()
if e.paused then
if not t then
t=se(f,l,j);
t:settimeout(0)
end
a=c(s,t,a)
n[t]=e
e.paused=false;
end
end
e.ip=function()
return f
end
e.serverport=function()
return l
end
e.socket=function()
return t
end
e.readbuffer=function()
if a>=k or o>=k then
e.pause()
i("server.lua: refused new client connection: server full")
return false
end
local t,a=b(t)
if t then
local a,o=t:getpeername()
local e,n,t=R(e,w,t,a,l,o,v,m)
if t then
return false
end
u=u+1
i("server.lua: accepted new client connection from ",h(a),":",h(o)," to ",h(l))
if y and not m then
return y(e);
end
return;
elseif a then
i("server.lua: error with new client connection: ",h(a))
return false
end
end
return e
end
R=function(_,y,t,z,Q,E,T,j)
if t:getfd()>=q then
U("server.lua: Disallowed FD number: "..t:getfd())
t:close()
if _ then
_.pause()
end
return nil,nil,"fd-too-large"
end
t:settimeout(0)
local p
local A
local q
local D
local R=y.onincoming
local U=y.onstatus
local k=y.ondisconnect
local L=y.ondrain
local C=y.ondetach
local v={}
local l=0
local V
local B
local M
local f=0
local g=false
local H=false
local Y,P=0,0
local O=O
local I=I
local e=v
e.dispatch=function()
return R
end
e.disconnect=function()
return k
end
e.setlistener=function(a,t)
if C then
C(a)
end
R=t.onincoming
k=t.ondisconnect
U=t.onstatus
L=t.ondrain
C=t.ondetach
end
e.getstats=function()
return P,Y
end
e.ssl=function()
return D
end
e.sslctx=function()
return j
end
e.send=function(n,i,o,a)
return p(t,i,o,a)
end
e.receive=function(o,a)
return A(t,o,a)
end
e.shutdown=function(a)
return q(t,a)
end
e.setoption=function(i,a,o)
if t.setoption then
return t:setoption(a,o);
end
return false,"setoption not implemented";
end
e.force_close=function(t,a)
if l~=0 then
i("server.lua: discarding unwritten data for ",h(z),":",h(E))
l=0;
end
return t:close(a);
end
e.close=function(u,h)
if not e then return true;end
a=r(s,t,a)
b[e]=nil
if l~=0 then
e.sendbuffer()
if l~=0 then
if e then
e.write=nil
end
V=true
return false
end
end
if t then
m=q and q(t)
t:close()
o=r(d,t,o)
n[t]=nil
t=nil
else
i"server.lua: socket already closed"
end
if e then
w[e]=nil
S[e]=nil
local t=e;
e=nil
if k then
k(t,h or false);
k=nil
end
end
if _ then
_.remove()
end
i"server.lua: closed client handler and removed socket from list"
return true
end
e.ip=function()
return z
end
e.serverport=function()
return Q
end
e.clientport=function()
return E
end
e.port=e.clientport
local k=function(i,a)
f=f+#a
if f>O then
S[e]="send buffer exceeded"
e.write=K
return false
elseif t and not d[t]then
o=c(d,t,o)
end
l=l+1
v[l]=a
if e then
w[e]=w[e]or u
end
return true
end
e.write=k
e.bufferqueue=function(t)
return v
end
e.socket=function(a)
return t
end
e.set_mode=function(a,t)
T=t or T
return T
end
e.set_send=function(a,t)
p=t or p
return p
end
e.bufferlen=function(o,a,t)
O=t or O
I=a or I
return f,I,O
end
e.lock_read=function(i,o)
if o==true then
local o=a
a=r(s,t,a)
b[e]=nil
if a~=o then
g=true
end
elseif o==false then
if g then
g=false
a=c(s,t,a)
b[e]=u
end
end
return g
end
e.pause=function(t)
return t:lock_read(true);
end
e.resume=function(t)
return t:lock_read(false);
end
e.lock=function(i,a)
e.lock_read(a)
if a==true then
e.write=K
local a=o
o=r(d,t,o)
w[e]=nil
if o~=a then
H=true
end
elseif a==false then
e.write=k
if H then
H=false
k("")
end
end
return g,H
end
local b=function()
local o,t,a=A(t,T)
if not t or(t=="wantread"or t=="timeout")then
local o=o or a or""
local a=#o
if a>I then
e:close("receive buffer exceeded")
return false
end
local a=a*X
P=P+a
F=F+a
b[e]=u
return R(e,o,t)
else
i("server.lua: client ",h(z),":",h(E)," read error: ",h(t))
B=true
m=e and e:force_close(t)
return false
end
end
local v=function()
local y,a,s,n,c;
if t then
n=pe(v,"",1,l)
y,a,s=p(t,n,1,f)
c=(y or s or 0)*X
Y=Y+c
W=W+c
for e=l,1,-1 do
v[e]=nil
end
else
y,a,c=false,"unexpected close",0;
end
if y then
l=0
f=0
o=r(d,t,o)
w[e]=nil
if L then
L(e)
end
m=M and e:starttls(nil)
m=V and e:force_close()
return true
elseif s and(a=="timeout"or a=="wantwrite")then
n=ye(n,s+1,f)
v[1]=n
l=1
f=f-s
w[e]=u
return true
else
i("server.lua: client ",h(z),":",h(E)," write error: ",h(a))
B=true
m=e and e:force_close(a)
return false
end
end
local u;
function e.set_sslctx(w,t)
j=t;
local l,f
u=fe(function(n)
local t
for h=1,x do
o=(f and r(d,n,o))or o
a=(l and r(s,n,a))or a
l,f=nil,nil
m,t=n:dohandshake()
if not t then
i("server.lua: ssl handshake done")
e.readbuffer=b
e.sendbuffer=v
m=U and U(e,"ssl-handshake-complete")
if w.autostart_ssl and y.onconnect then
y.onconnect(w);
end
a=c(s,n,a)
return true
else
if t=="wantwrite"then
o=c(d,n,o)
f=true
elseif t=="wantread"then
a=c(s,n,a)
l=true
else
break;
end
t=nil;
we()
end
end
i("server.lua: ssl handshake error: ",h(t or"handshake too long"))
m=e and e:force_close("ssl handshake failed")
return false,t
end
)
end
if N then
e.starttls=function(f,m)
if m then
e:set_sslctx(m);
end
if l>0 then
i"server.lua: we need to do tls, but delaying until send buffer empty"
M=true
return
end
i("server.lua: attempting to start tls on "..h(t))
local m,l=t
t,l=me(t,j)
if not t then
i("server.lua: error while starting tls on client: ",h(l or"unknown error"))
return nil,l
end
t:settimeout(0)
p=t.send
A=t.receive
q=G
n[t]=e
a=c(s,t,a)
a=r(s,m,a)
o=r(d,m,o)
n[m]=nil
e.starttls=nil
M=nil
D=true
e.readbuffer=u
e.sendbuffer=u
return u(t)
end
end
e.readbuffer=b
e.sendbuffer=v
p=t.send
A=t.receive
q=(D and G)or t.shutdown
n[t]=e
a=c(s,t,a)
if j and N then
i"server.lua: auto-starting ssl negotiation..."
e.autostart_ssl=true;
local e,t=e:starttls(j);
if e==false then
return nil,nil,t
end
end
return e,t
end
G=function()
end
K=function()
return false
end
c=function(a,t,e)
if not a[t]then
e=e+1
a[e]=t
a[t]=e
end
return e;
end
r=function(e,a,t)
local i=e[a]
if i then
e[a]=nil
local o=e[t]
e[t]=nil
if o~=a then
e[o]=i
e[i]=o
end
return t-1
end
return t
end
B=function(e)
o=r(d,e,o)
a=r(s,e,a)
n[e]=nil
e:close()
end
local function f(e,t,o)
local a;
local i=t.sendbuffer;
function t.sendbuffer()
i();
if a and t.bufferlen()<o then
e:lock_read(false);
a=nil;
end
end
local i=e.readbuffer;
function e.readbuffer()
i();
if not a and t.bufferlen()>=o then
a=true;
e:lock_read(true);
end
end
e:set_mode("*a");
end
ae=function(t,e,d,l,r)
local o
if D(d)~="table"then
o="invalid listener table"
end
if D(e)~="number"or not(e>=0 and e<=65535)then
o="invalid port"
elseif p[t..":"..e]then
o="listeners on '["..t.."]:"..e.."' already exist"
elseif r and not N then
o="luasec not found"
end
if o then
U("server.lua, [",t,"]:",e,": ",o)
return nil,o
end
t=t or"*"
local o,h=se(t,e,j)
if h then
U("server.lua, [",t,"]:",e,": ",h)
return nil,h
end
local h,d=he(d,o,t,e,l,r)
if not h then
o:close()
return nil,d
end
o:settimeout(0)
a=c(s,o,a)
p[t..":"..e]=h
n[o]=h
i("server.lua: new "..(r and"ssl "or"").."server listener on '[",t,"]:",e,"'")
return h
end
oe=function(e,t)
return p[e..":"..t];
end
de=function(t,e)
local a=p[t..":"..e]
if not a then
return nil,"no server found on '["..t.."]:"..h(e).."'"
end
a:close()
p[t..":"..e]=nil
return true
end
ne=function()
for e,t in L(n)do
t:close()
n[e]=nil
end
a=0
o=0
g=0
p={}
s={}
d={}
H={}
n={}
end
re=function()
return{
select_timeout=E;
select_sleep_time=A;
tcp_backlog=j;
max_send_buffer_size=O;
max_receive_buffer_size=I;
select_idle_check_interval=_;
send_timeout=T;
read_timeout=z;
max_connections=k;
max_ssl_handshake_roundtrips=x;
highest_allowed_fd=q;
}
end
le=function(e)
if D(e)~="table"then
return nil,"invalid settings table"
end
E=y(e.select_timeout)or E
A=y(e.select_sleep_time)or A
O=y(e.max_send_buffer_size)or O
I=y(e.max_receive_buffer_size)or I
_=y(e.select_idle_check_interval)or _
j=y(e.tcp_backlog)or j
T=y(e.send_timeout)or T
z=y(e.read_timeout)or z
k=e.max_connections or k
x=e.max_ssl_handshake_roundtrips or x
q=e.highest_allowed_fd or q
return true
end
te=function(e)
if D(e)~="function"then
return nil,"invalid listener function"
end
g=g+1
H[g]=e
return true
end
ie=function()
return F,W,a,o,g
end
local t;
local function y(e)
t=not not e;
end
Q=function(a)
if t then return"quitting";end
if a then t="once";end
local e=ee;
repeat
local o,a,s=ue(s,d,P(E,e))
for t,e in Z(a)do
local t=n[e]
if t then
t.sendbuffer()
else
B(e)
i"server.lua: found no handler and closed socket (writelist)"
end
end
for t,e in Z(o)do
local t=n[e]
if t then
t.readbuffer()
else
B(e)
i"server.lua: found no handler and closed socket (readlist)"
end
end
for e,t in L(S)do
e.disconnect()(e,t)
e:force_close()
S[e]=nil;
end
u=V()
local a=Y(u-J)
if a>_ then
J=u
for e,t in L(w)do
if Y(u-t)>T then
e.disconnect()(e,"send timeout")
e:force_close()
end
end
for e,t in L(b)do
if Y(u-t)>z then
e.disconnect()(e,"read timeout")
e:close()
end
end
end
if u-M>=P(e,1)then
e=ee;
for t=1,g do
local t=H[t](u)
if t then e=P(e,t);end
end
M=u
else
e=e-(u-M);
end
ce(A)
until t;
if a and t=="once"then t=nil;return;end
return"quitting"
end
local function h()
return Q(true);
end
local function r()
return"select";
end
local s=function(e,s,a,t,h,i)
local e,a,s=R(nil,t,e,s,a,"clientport",h,i)
if not e then return nil,s end
n[a]=e
if not i then
o=c(d,a,o)
if t.onconnect then
local a=e.sendbuffer;
e.sendbuffer=function()
e.sendbuffer=a;
t.onconnect(e);
return a();
end
end
end
return e,a
end
local t=function(o,a,i,n,h)
local t,e=v.tcp()
if e then
return nil,e
end
t:settimeout(0)
m,e=t:connect(o,a)
if e then
local e=s(t,o,a,i)
else
R(nil,i,t,o,a,"clientport",n,h)
end
end
l"setmetatable"(n,{__mode="k"})
l"setmetatable"(b,{__mode="k"})
l"setmetatable"(w,{__mode="k"})
M=V()
J=V()
local function a(e)
local t=C;
if e then
C=e;
end
return t;
end
return{
_addtimer=te,
addclient=t,
wrapclient=s,
loop=Q,
link=f,
step=h,
stats=ie,
closeall=ne,
addserver=ae,
getserver=oe,
setlogger=a,
getsettings=re,
setquitting=y,
removeserver=de,
get_backend=r,
changesettings=le,
}
end)
package.preload['util.xmppstream']=(function(...)
local e=require"lxp";
local t=require"util.stanza";
local w=t.stanza_mt;
local f=error;
local t=tostring;
local d=table.insert;
local y=table.concat;
local _=table.remove;
local p=setmetatable;
local z=pcall(e.new,{StartDoctypeDecl=false});
local T=pcall(e.new,{XmlDecl=false});
local a=not not e.new({}).getcurrentbytecount;
local E=1024*1024*10;
module"xmppstream"
local k=e.new;
local x={
["http://www.w3.org/XML/1998/namespace\1lang"]="xml:lang";
["http://www.w3.org/XML/1998/namespace\1space"]="xml:space";
["http://www.w3.org/XML/1998/namespace\1base"]="xml:base";
["http://www.w3.org/XML/1998/namespace\1id"]="xml:id";
};
local h="http://etherx.jabber.org/streams";
local r="\1";
local g="^([^"..r.."]*)"..r.."?(.*)$";
_M.ns_separator=r;
_M.ns_pattern=g;
local function s()end
function new_sax_handlers(i,e,n)
local o={};
local v=e.streamopened;
local b=e.streamclosed;
local l=e.error or function(o,a,e)f("XML stream error: "..t(a)..(e and": "..t(e)or""),2);end;
local j=e.handlestanza;
n=n or s;
local t=e.stream_ns or h;
local m=e.stream_tag or"stream";
if t~=""then
m=t..r..m;
end
local q=t..r..(e.error_tag or"error");
local k=e.default_ns;
local u={};
local s,e={};
local t=0;
local h=0;
function o:StartElement(c,o)
if e and#s>0 then
d(e,y(s));
s={};
end
local r,s=c:match(g);
if s==""then
r,s="",r;
end
if r~=k or h>0 then
o.xmlns=r;
h=h+1;
end
for t=1,#o do
local e=o[t];
o[t]=nil;
local t=x[e];
if t then
o[t]=o[e];
o[e]=nil;
end
end
if not e then
if a then
t=self:getcurrentbytecount();
end
if i.notopen then
if c==m then
h=0;
if v then
if a then
n(t);
t=0;
end
v(i,o);
end
else
l(i,"no-stream",c);
end
return;
end
if r=="jabber:client"and s~="iq"and s~="presence"and s~="message"then
l(i,"invalid-top-level-element");
end
e=p({name=s,attr=o,tags={}},w);
else
if a then
t=t+self:getcurrentbytecount();
end
d(u,e);
local t=e;
e=p({name=s,attr=o,tags={}},w);
d(t,e);
d(t.tags,e);
end
end
if T then
function o:XmlDecl(e,e,e)
if a then
n(self:getcurrentbytecount());
end
end
end
function o:StartCdataSection()
if a then
if e then
t=t+self:getcurrentbytecount();
else
n(self:getcurrentbytecount());
end
end
end
function o:EndCdataSection()
if a then
if e then
t=t+self:getcurrentbytecount();
else
n(self:getcurrentbytecount());
end
end
end
function o:CharacterData(o)
if e then
if a then
t=t+self:getcurrentbytecount();
end
d(s,o);
elseif a then
n(self:getcurrentbytecount());
end
end
function o:EndElement(o)
if a then
t=t+self:getcurrentbytecount()
end
if h>0 then
h=h-1;
end
if e then
if#s>0 then
d(e,y(s));
s={};
end
if#u==0 then
if a then
n(t);
end
t=0;
if o~=q then
j(i,e);
else
l(i,"stream-error",e);
end
e=nil;
else
e=_(u);
end
else
if b then
b(i);
end
end
end
local function a(e)
l(i,"parse-error","restricted-xml","Restricted XML, see RFC 6120 section 11.1.");
if not e.stop or not e:stop()then
f("Failed to abort parsing");
end
end
if z then
o.StartDoctypeDecl=a;
end
o.Comment=a;
o.ProcessingInstruction=a;
local function a()
e,s,t=nil,{},0;
u={};
end
local function e(t,e)
i=e;
end
return o,{reset=a,set_session=e};
end
function new(i,n,o)
local e=0;
local t;
if a then
function t(t)
e=e-t;
end
o=o or E;
elseif o then
f("Stanza size limits are not supported on this version of LuaExpat")
end
local i,n=new_sax_handlers(i,n,t);
local t=k(i,r,false);
local s=t.parse;
return{
reset=function()
t=k(i,r,false);
s=t.parse;
e=0;
n.reset();
end,
feed=function(n,i)
if a then
e=e+#i;
end
local i,t=s(t,i);
if a and e>o then
return nil,"stanza-too-large";
end
return i,t;
end,
set_session=n.set_session;
};
end
return _M;
end)
package.preload['util.jid']=(function(...)
local a,i=string.match,string.sub;
local r=require"util.encodings".stringprep.nodeprep;
local d=require"util.encodings".stringprep.nameprep;
local l=require"util.encodings".stringprep.resourceprep;
local h={
[" "]="\\20";['"']="\\22";
["&"]="\\26";["'"]="\\27";
["/"]="\\2f";[":"]="\\3a";
["<"]="\\3c";[">"]="\\3e";
["@"]="\\40";["\\"]="\\5c";
};
local n={};
for e,t in pairs(h)do n[t]=e;end
module"jid"
local function o(e)
if not e then return;end
local i,t=a(e,"^([^@/]+)@()");
local t,o=a(e,"^([^@/]+)()",t)
if i and not t then return nil,nil,nil;end
local a=a(e,"^/(.+)$",o);
if(not t)or((not a)and#e>=o)then return nil,nil,nil;end
return i,t,a;
end
split=o;
function bare(e)
local t,e=o(e);
if t and e then
return t.."@"..e;
end
return e;
end
local function s(e)
local t,e,a=o(e);
if e then
if i(e,-1,-1)=="."then
e=i(e,1,-2);
end
e=d(e);
if not e then return;end
if t then
t=r(t);
if not t then return;end
end
if a then
a=l(a);
if not a then return;end
end
return t,e,a;
end
end
prepped_split=s;
function prep(e)
local a,e,t=s(e);
if e then
if a then
e=a.."@"..e;
end
if t then
e=e.."/"..t;
end
end
return e;
end
function join(a,e,t)
if a and e and t then
return a.."@"..e.."/"..t;
elseif a and e then
return a.."@"..e;
elseif e and t then
return e.."/"..t;
elseif e then
return e;
end
return nil;
end
function compare(t,e)
local n,i,s=o(t);
local t,a,e=o(e);
if((t~=nil and t==n)or t==nil)and
((a~=nil and a==i)or a==nil)and
((e~=nil and e==s)or e==nil)then
return true
end
return false
end
function escape(e)return e and(e:gsub(".",h));end
function unescape(e)return e and(e:gsub("\\%x%x",n));end
return _M;
end)
package.preload['util.events']=(function(...)
local o=pairs;
local h=table.insert;
local s=table.sort;
local d=setmetatable;
local n=next;
module"events"
function new()
local t={};
local e={};
local function r(i,a)
local e=e[a];
if not e or n(e)==nil then return;end
local t={};
for e in o(e)do
h(t,e);
end
s(t,function(a,t)return e[a]>e[t];end);
i[a]=t;
return t;
end;
d(t,{__index=r});
local function s(o,n,i)
local a=e[o];
if a then
a[n]=i or 0;
else
a={[n]=i or 0};
e[o]=a;
end
t[o]=nil;
end;
local function i(o,i)
local a=e[o];
if a then
a[i]=nil;
t[o]=nil;
if n(a)==nil then
e[o]=nil;
end
end
end;
local function a(e)
for e,t in o(e)do
s(e,t);
end
end;
local function n(e)
for t,e in o(e)do
i(t,e);
end
end;
local function o(e,...)
local e=t[e];
if e then
for t=1,#e do
local e=e[t](...);
if e~=nil then return e;end
end
end
end;
return{
add_handler=s;
remove_handler=i;
add_handlers=a;
remove_handlers=n;
fire_event=o;
_handlers=t;
_event_map=e;
};
end
return _M;
end)
package.preload['util.dataforms']=(function(...)
local a=setmetatable;
local e,i=pairs,ipairs;
local n,s,c=tostring,type,next;
local h=table.concat;
local l=require"util.stanza";
local d=require"util.jid".prep;
module"dataforms"
local u='jabber:x:data';
local r={};
local e={__index=r};
function new(t)
return a(t,e);
end
function from_stanza(e)
local o={
title=e:get_child_text("title");
instructions=e:get_child_text("instructions");
};
for e in e:childtags("field")do
local a={
name=e.attr.var;
label=e.attr.label;
type=e.attr.type;
required=e:get_child("required")and true or nil;
value=e:get_child_text("value");
};
o[#o+1]=a;
if a.type then
local t={};
if a.type:match"list%-"then
for e in e:childtags("option")do
t[#t+1]={label=e.attr.label,value=e:get_child_text("value")};
end
for e in e:childtags("value")do
t[#t+1]={label=e.attr.label,value=e:get_text(),default=true};
end
elseif a.type:match"%-multi"then
for e in e:childtags("value")do
t[#t+1]=e.attr.label and{label=e.attr.label,value=e:get_text()}or e:get_text();
end
if a.type=="text-multi"then
a.value=h(t,"\n");
else
a.value=t;
end
end
end
end
return new(o);
end
function r.form(t,a,e)
local e=l.stanza("x",{xmlns=u,type=e or"form"});
if t.title then
e:tag("title"):text(t.title):up();
end
if t.instructions then
e:tag("instructions"):text(t.instructions):up();
end
for t,o in i(t)do
local t=o.type or"text-single";
e:tag("field",{type=t,var=o.name,label=o.label});
local a=(a and a[o.name])or o.value;
if a then
if t=="hidden"then
if s(a)=="table"then
e:tag("value")
:add_child(a)
:up();
else
e:tag("value"):text(n(a)):up();
end
elseif t=="boolean"then
e:tag("value"):text((a and"1")or"0"):up();
elseif t=="fixed"then
elseif t=="jid-multi"then
for a,t in i(a)do
e:tag("value"):text(t):up();
end
elseif t=="jid-single"then
e:tag("value"):text(a):up();
elseif t=="text-single"or t=="text-private"then
e:tag("value"):text(a):up();
elseif t=="text-multi"then
for t in a:gmatch("([^\r\n]+)\r?\n*")do
e:tag("value"):text(t):up();
end
elseif t=="list-single"then
local o=false;
for a,t in i(a)do
if s(t)=="table"then
e:tag("option",{label=t.label}):tag("value"):text(t.value):up():up();
if t.default and(not o)then
e:tag("value"):text(t.value):up();
o=true;
end
else
e:tag("option",{label=t}):tag("value"):text(n(t)):up():up();
end
end
elseif t=="list-multi"then
for a,t in i(a)do
if s(t)=="table"then
e:tag("option",{label=t.label}):tag("value"):text(t.value):up():up();
if t.default then
e:tag("value"):text(t.value):up();
end
else
e:tag("option",{label=t}):tag("value"):text(n(t)):up():up();
end
end
end
end
if o.required then
e:tag("required"):up();
end
e:up();
end
return e;
end
local e={};
function r.data(t,s)
local n={};
local a={};
for o,t in i(t)do
local o;
for e in s:childtags()do
if t.name==e.attr.var then
o=e;
break;
end
end
if not o then
if t.required then
a[t.name]="Required value missing";
end
else
local e=e[t.type];
if e then
n[t.name],a[t.name]=e(o,t.required);
end
end
end
if c(a)then
return n,a;
end
return n;
end
e["text-single"]=
function(t,a)
local t=t:get_child_text("value");
if t and#t>0 then
return t
elseif a then
return nil,"Required value missing";
end
end
e["text-private"]=
e["text-single"];
e["jid-single"]=
function(t,o)
local t=t:get_child_text("value")
local a=d(t);
if a and#a>0 then
return a
elseif t then
return nil,"Invalid JID: "..t;
elseif o then
return nil,"Required value missing";
end
end
e["jid-multi"]=
function(o,i)
local t={};
local a={};
for e in o:childtags("value")do
local e=e:get_text();
local o=d(e);
t[#t+1]=o;
if e and not o then
a[#a+1]=("Invalid JID: "..e);
end
end
if#t>0 then
return t,(#a>0 and h(a,"\n")or nil);
elseif i then
return nil,"Required value missing";
end
end
e["list-multi"]=
function(a,o)
local t={};
for e in a:childtags("value")do
t[#t+1]=e:get_text();
end
return t,(o and#t==0 and"Required value missing"or nil);
end
e["text-multi"]=
function(t,a)
local t,a=e["list-multi"](t,a);
if t then
t=h(t,"\n");
end
return t,a;
end
e["list-single"]=
e["text-single"];
local a={
["1"]=true,["true"]=true,
["0"]=false,["false"]=false,
};
e["boolean"]=
function(t,o)
local t=t:get_child_text("value");
local a=a[t~=nil and t];
if a~=nil then
return a;
elseif t then
return nil,"Invalid boolean representation";
elseif o then
return nil,"Required value missing";
end
end
e["hidden"]=
function(e)
return e:get_child_text("value");
end
return _M;
end)
package.preload['util.caps']=(function(...)
local d=require"util.encodings".base64.encode;
local l=require"util.hashes".sha1;
local n,h,s=table.insert,table.sort,table.concat;
local r=ipairs;
module"caps"
function calculate_hash(e)
local a,o,i={},{},{};
for t,e in r(e)do
if e.name=="identity"then
n(a,(e.attr.category or"").."\0"..(e.attr.type or"").."\0"..(e.attr["xml:lang"]or"").."\0"..(e.attr.name or""));
elseif e.name=="feature"then
n(o,e.attr.var or"");
elseif e.name=="x"and e.attr.xmlns=="jabber:x:data"then
local t={};
local o;
for a,e in r(e.tags)do
if e.name=="field"and e.attr.var then
local a={};
for t,e in r(e.tags)do
e=#e.tags==0 and e:get_text();
if e then n(a,e);end
end
h(a);
if e.attr.var=="FORM_TYPE"then
o=a[1];
elseif#a>0 then
n(t,e.attr.var.."\0"..s(a,"<"));
else
n(t,e.attr.var);
end
end
end
h(t);
t=s(t,"<");
if o then t=o.."\0"..t;end
n(i,t);
end
end
h(a);
h(o);
h(i);
if#a>0 then a=s(a,"<"):gsub("%z","/").."<";else a="";end
if#o>0 then o=s(o,"<").."<";else o="";end
if#i>0 then i=s(i,"<"):gsub("%z","<").."<";else i="";end
local e=a..o..i;
local t=d(l(e));
return t,e;
end
return _M;
end)
package.preload['util.vcard']=(function(...)
local i=require"util.stanza";
local a,c=table.insert,table.concat;
local s=type;
local e,h,m=next,pairs,ipairs;
local r,d,l,u;
local f="\n";
local o;
local function e()
error"Not implemented"
end
local function e()
error"Not implemented"
end
local function w(e)
return e:gsub("[,:;\\]","\\%1"):gsub("\n","\\n");
end
local function y(e)
return e:gsub("\\?[\\nt:;,]",{
["\\\\"]="\\",
["\\n"]="\n",
["\\r"]="\r",
["\\t"]="\t",
["\\:"]=":",
["\\;"]=";",
["\\,"]=",",
[":"]="\29",
[";"]="\30",
[","]="\31",
});
end
local function p(t)
local a=i.stanza(t.name,{xmlns="vcard-temp"});
local e=o[t.name];
if e=="text"then
a:text(t[1]);
elseif s(e)=="table"then
if e.types and t.TYPE then
if s(t.TYPE)=="table"then
for o,e in h(e.types)do
for o,t in h(t.TYPE)do
if t:upper()==e then
a:tag(e):up();
break;
end
end
end
else
a:tag(t.TYPE:upper()):up();
end
end
if e.props then
for o,e in h(e.props)do
if t[e]then
a:tag(e):up();
end
end
end
if e.value then
a:tag(e.value):text(t[1]):up();
elseif e.values then
local o=e.values;
local i=o.behaviour=="repeat-last"and o[#o];
for o=1,#t do
a:tag(e.values[o]or i):text(t[o]):up();
end
end
end
return a;
end
local function n(t)
local e=i.stanza("vCard",{xmlns="vcard-temp"});
for a=1,#t do
e:add_child(p(t[a]));
end
return e;
end
function u(e)
if not e[1]or e[1].name then
return n(e)
else
local t=i.stanza("xCard",{xmlns="vcard-temp"});
for a=1,#e do
t:add_child(n(e[a]));
end
return t;
end
end
function r(t)
t=t
:gsub("\r\n","\n")
:gsub("\n ","")
:gsub("\n\n+","\n");
local s={};
local e;
for t in t:gmatch("[^\n]+")do
local t=y(t);
local n,t,i=t:match("^([-%a]+)(\30?[^\29]*)\29(.*)$");
i=i:gsub("\29",":");
if#t>0 then
local a={};
for e,o,i in t:gmatch("\30([^=]+)(=?)([^\30]*)")do
e=e:upper();
local t={};
for e in i:gmatch("[^\31]+")do
t[#t+1]=e
t[e]=true;
end
if o=="="then
a[e]=t;
else
a[e]=true;
end
end
t=a;
end
if n=="BEGIN"and i=="VCARD"then
e={};
s[#s+1]=e;
elseif n=="END"and i=="VCARD"then
e=nil;
elseif e and o[n]then
local o=o[n];
local n={name=n};
e[#e+1]=n;
local s=e;
e=n;
if o.types then
for o,a in m(o.types)do
local a=a:lower();
if(t.TYPE and t.TYPE[a]==true)
or t[a]==true then
e.TYPE=a;
end
end
end
if o.props then
for o,a in m(o.props)do
if t[a]then
if t[a]==true then
e[a]=true;
else
for o,t in m(t[a])do
e[a]=t;
end
end
end
end
end
if o=="text"or o.value then
a(e,i);
elseif o.values then
local t="\30"..i;
for t in t:gmatch("\30([^\30]*)")do
a(e,t);
end
end
e=s;
end
end
return s;
end
local function i(t)
local e={};
for a=1,#t do
e[a]=w(t[a]);
end
e=c(e,";");
local a="";
for t,e in h(t)do
if s(t)=="string"and t~="name"then
a=a..(";%s=%s"):format(t,s(e)=="table"and c(e,",")or e);
end
end
return("%s%s:%s"):format(t.name,a,e)
end
local function t(t)
local e={};
a(e,"BEGIN:VCARD")
for o=1,#t do
a(e,i(t[o]));
end
a(e,"END:VCARD")
return c(e,f);
end
function d(e)
if e[1]and e[1].name then
return t(e)
else
local a={};
for o=1,#e do
a[o]=t(e[o]);
end
return c(a,f);
end
end
local function n(i)
local t=i.name;
local e=o[t];
local t={name=t};
if e=="text"then
t[1]=i:get_text();
elseif s(e)=="table"then
if e.value then
t[1]=i:get_child_text(e.value)or"";
elseif e.values then
local e=e.values;
if e.behaviour=="repeat-last"then
for e=1,#i.tags do
a(t,i.tags[e]:get_text()or"");
end
else
for o=1,#e do
a(t,i:get_child_text(e[o])or"");
end
end
elseif e.names then
local e=e.names;
for a=1,#e do
if i:get_child(e[a])then
t[1]=e[a];
break;
end
end
end
if e.props_verbatim then
for a,e in h(e.props_verbatim)do
t[a]=e;
end
end
if e.types then
local e=e.types;
t.TYPE={};
for o=1,#e do
if i:get_child(e[o])then
a(t.TYPE,e[o]:lower());
end
end
if#t.TYPE==0 then
t.TYPE=nil;
end
end
if e.props then
local e=e.props;
for o=1,#e do
local e=e[o]
local o=i:get_child_text(e);
if o then
t[e]=t[e]or{};
a(t[e],o);
end
end
end
else
return nil
end
return t;
end
local function i(e)
local e=e.tags;
local t={};
for o=1,#e do
a(t,n(e[o]));
end
return t
end
function l(e)
if e.attr.xmlns~="vcard-temp"then
return nil,"wrong-xmlns";
end
if e.name=="xCard"then
local t={};
local e=e.tags;
for a=1,#e do
t[a]=i(e[a]);
end
return t
elseif e.name=="vCard"then
return i(e)
end
end
o={
VERSION="text",
FN="text",
N={
values={
"FAMILY",
"GIVEN",
"MIDDLE",
"PREFIX",
"SUFFIX",
},
},
NICKNAME="text",
PHOTO={
props_verbatim={ENCODING={"b"}},
props={"TYPE"},
value="BINVAL",
},
BDAY="text",
ADR={
types={
"HOME",
"WORK",
"POSTAL",
"PARCEL",
"DOM",
"INTL",
"PREF",
},
values={
"POBOX",
"EXTADD",
"STREET",
"LOCALITY",
"REGION",
"PCODE",
"CTRY",
}
},
LABEL={
types={
"HOME",
"WORK",
"POSTAL",
"PARCEL",
"DOM",
"INTL",
"PREF",
},
value="LINE",
},
TEL={
types={
"HOME",
"WORK",
"VOICE",
"FAX",
"PAGER",
"MSG",
"CELL",
"VIDEO",
"BBS",
"MODEM",
"ISDN",
"PCS",
"PREF",
},
value="NUMBER",
},
EMAIL={
types={
"HOME",
"WORK",
"INTERNET",
"PREF",
"X400",
},
value="USERID",
},
JABBERID="text",
MAILER="text",
TZ="text",
GEO={
values={
"LAT",
"LON",
},
},
TITLE="text",
ROLE="text",
LOGO="copy of PHOTO",
AGENT="text",
ORG={
values={
behaviour="repeat-last",
"ORGNAME",
"ORGUNIT",
}
},
CATEGORIES={
values="KEYWORD",
},
NOTE="text",
PRODID="text",
REV="text",
SORTSTRING="text",
SOUND="copy of PHOTO",
UID="text",
URL="text",
CLASS={
names={
"PUBLIC",
"PRIVATE",
"CONFIDENTIAL",
},
},
KEY={
props={"TYPE"},
value="CRED",
},
DESC="text",
};
o.LOGO=o.PHOTO;
o.SOUND=o.PHOTO;
return{
from_text=r;
to_text=d;
from_xep54=l;
to_xep54=u;
lua_to_text=d;
lua_to_xep54=u;
text_to_lua=r;
text_to_xep54=function(...)return u(r(...));end;
xep54_to_lua=l;
xep54_to_text=function(...)return d(l(...))end;
};
end)
package.preload['util.logger']=(function(...)
local e=pcall;
local e=string.find;
local e,s,e=ipairs,pairs,setmetatable;
module"logger"
local e={};
local t;
function init(e)
local n=t(e,"debug");
local i=t(e,"info");
local o=t(e,"warn");
local a=t(e,"error");
return function(e,t,...)
if e=="debug"then
return n(t,...);
elseif e=="info"then
return i(t,...);
elseif e=="warn"then
return o(t,...);
elseif e=="error"then
return a(t,...);
end
end
end
function t(o,a)
local t=e[a];
if not t then
t={};
e[a]=t;
end
local e=function(e,...)
for i=1,#t do
t[i](o,a,e,...);
end
end
return e;
end
function reset()
for t,e in s(e)do
for t=1,#e do
e[t]=nil;
end
end
end
function add_level_sink(t,a)
if not e[t]then
e[t]={a};
else
e[t][#e[t]+1]=a;
end
end
_M.new=t;
return _M;
end)
package.preload['util.datetime']=(function(...)
local e=os.date;
local i=os.time;
local u=os.difftime;
local t=error;
local l=tonumber;
module"datetime"
function date(t)
return e("!%Y-%m-%d",t);
end
function datetime(t)
return e("!%Y-%m-%dT%H:%M:%SZ",t);
end
function time(t)
return e("!%H:%M:%S",t);
end
function legacy(t)
return e("!%Y%m%dT%H:%M:%S",t);
end
function parse(o)
if o then
local n,r,s,h,d,t,a;
n,r,s,h,d,t,a=o:match("^(%d%d%d%d)%-?(%d%d)%-?(%d%d)T(%d%d):(%d%d):(%d%d)%.?%d*([Z+%-]?.*)$");
if n then
local u=u(i(e("*t")),i(e("!*t")));
local o=0;
if a~=""and a~="Z"then
local a,t,e=a:match("([+%-])(%d%d):?(%d*)");
if not a then return;end
if#e~=2 then e="0";end
t,e=l(t),l(e);
o=t*60*60+e*60;
if a=="-"then o=-o;end
end
t=(t+u)-o;
return i({year=n,month=r,day=s,hour=h,min=d,sec=t,isdst=false});
end
end
end
return _M;
end)
package.preload['util.sasl.scram']=(function(...)
local i,n=require"mime".b64,require"mime".unb64;
local a=require"crypto";
local t=require"bit";
local u=tonumber;
local s,e=string.char,string.byte;
local o=string.gsub;
local h=t.bxor;
local function r(a,t)
return(o(a,"()(.)",function(o,a)
return s(h(e(a),e(t,o)))
end));
end
local function y(e)
return a.digest("sha1",e,true);
end
local s=a.hmac.digest;
local function e(e,t)
return s("sha1",t,e,true);
end
local function w(o,t,i)
local t=e(o,t.."\0\0\0\1");
local a=t;
for i=2,i do
t=e(o,t);
a=r(a,t);
end
return a;
end
local function f(e)
return e;
end
local function t(e)
return(o(e,"[,=]",{[","]="=2C",["="]="=3D"}));
end
local function s(o,c)
local t="n="..t(o.username);
local s=i(a.rand.bytes(15));
local h="r="..s;
local d=t..","..h;
local l="";
local t=o.conn:ssl()and"y"or"n";
if c=="SCRAM-SHA-1-PLUS"then
l=o.conn:socket():getfinished();
t="p=tls-unique";
end
local m=t..",,";
local t=m..d;
local t,c=coroutine.yield(t);
if t~="challenge"then return false end
local t,a,p=c:match("(r=[^,]+),s=([^,]*),i=(%d+)");
local u=u(p);
a=n(a);
if not t or not a or not u then
return false,"Could not parse server_first_message";
elseif t:find(s,3,true)~=3 then
return false,"nonce sent by server does not match our nonce";
elseif t==h then
return false,"server did not append s-nonce to nonce";
end
local s=m..l;
local s="c="..i(s);
local s=s..","..t;
local o=w(f(o.password),a,u);
local t=e(o,"Client Key");
local h=y(t);
local a=d..","..c..","..s;
local h=e(h,a);
local h=r(t,h);
local t=e(o,"Server Key");
local e=e(t,a);
local t="p="..i(h);
local t=s..","..t;
local a,t=coroutine.yield(t);
if a~="success"then return false,"success-expected"end
local t=t:match("v=([^,]+)");
if n(t)~=e then
return false,"server signature did not match";
end
return true;
end
return function(e,t)
if e.username and(e.password or(e.client_key or e.server_key))then
if t=="SCRAM-SHA-1"then
return s,99;
elseif t=="SCRAM-SHA-1-PLUS"then
local e=e.conn:ssl()and e.conn:socket();
if e and e.getfinished then
return s,100;
end
end
end
end
end)
package.preload['util.sasl.plain']=(function(...)
return function(e,t)
if t=="PLAIN"and e.username and e.password then
return function(e)
return"success"==coroutine.yield("\0"..e.username.."\0"..e.password);
end,5;
end
end
end)
package.preload['util.sasl.anonymous']=(function(...)
return function(t,e)
if e=="ANONYMOUS"then
return function()
return coroutine.yield()=="success";
end,0;
end
end
end)
package.preload['verse.plugins.tls']=(function(...)
local a=require"verse";
local t="urn:ietf:params:xml:ns:xmpp-tls";
function a.plugins.tls(e)
local function o(o)
if e.authenticated then return;end
if o:get_child("starttls",t)and e.conn.starttls then
e:debug("Negotiating TLS...");
e:send(a.stanza("starttls",{xmlns=t}));
return true;
elseif not e.conn.starttls and not e.secure then
e:warn("SSL libary (LuaSec) not loaded, so TLS not available");
elseif not e.secure then
e:debug("Server doesn't offer TLS :(");
end
end
local function a(t)
if t.name=="proceed"then
e:debug("Server says proceed, handshake starting...");
e.conn:starttls({mode="client",protocol="sslv23",options="no_sslv2"},true);
end
end
local function i(t)
if t=="ssl-handshake-complete"then
e.secure=true;
e:debug("Re-opening stream...");
e:reopen();
end
end
e:hook("stream-features",o,400);
e:hook("stream/"..t,a);
e:hook("status",i,400);
return true;
end
end)
package.preload['verse.plugins.sasl']=(function(...)
local n,r=require"mime".b64,require"mime".unb64;
local o="urn:ietf:params:xml:ns:xmpp-sasl";
function verse.plugins.sasl(e)
local function h(t)
if e.authenticated then return;end
e:debug("Authenticating with SASL...");
local t=t:get_child("mechanisms",o);
if not t then return end
local a={};
local i={};
for t in t:childtags("mechanism")do
t=t:get_text();
e:debug("Server offers %s",t);
if not a[t]then
local n=t:match("[^-]+");
local s,o=pcall(require,"util.sasl."..n:lower());
if s then
e:debug("Loaded SASL %s module",n);
a[t],i[t]=o(e,t);
elseif not tostring(o):match("not found")then
e:debug("Loading failed: %s",tostring(o));
end
end
end
local t={};
for e in pairs(a)do
table.insert(t,e);
end
if not t[1]then
e:event("authentication-failure",{condition="no-supported-sasl-mechanisms"});
e:close();
return;
end
table.sort(t,function(e,t)return i[e]>i[t];end);
local t,i=t[1];
e:debug("Selecting %s mechanism...",t);
e.sasl_mechanism=coroutine.wrap(a[t]);
i=e:sasl_mechanism(t);
local t=verse.stanza("auth",{xmlns=o,mechanism=t});
if i then
t:text(n(i));
end
e:send(t);
return true;
end
local function i(t)
if t.name=="failure"then
local a=t.tags[1];
local t=t:get_child_text("text");
e:event("authentication-failure",{condition=a.name,text=t});
e:close();
return false;
end
local t,a=e.sasl_mechanism(t.name,r(t:get_text()));
if not t then
e:event("authentication-failure",{condition=a});
e:close();
return false;
elseif t==true then
e:event("authentication-success");
e.authenticated=true
e:reopen();
else
e:send(verse.stanza("response",{xmlns=o}):text(n(t)));
end
return true;
end
e:hook("stream-features",h,300);
e:hook("stream/"..o,i);
return true;
end
end)
package.preload['verse.plugins.bind']=(function(...)
local t=require"verse";
local i=require"util.jid";
local a="urn:ietf:params:xml:ns:xmpp-bind";
function t.plugins.bind(e)
local function o(o)
if e.bound then return;end
e:debug("Binding resource...");
e:send_iq(t.iq({type="set"}):tag("bind",{xmlns=a}):tag("resource"):text(e.resource),
function(t)
if t.attr.type=="result"then
local t=t
:get_child("bind",a)
:get_child_text("jid");
e.username,e.host,e.resource=i.split(t);
e.jid,e.bound=t,true;
e:event("bind-success",{jid=t});
elseif t.attr.type=="error"then
local a=t:child_with_name("error");
local a,o,t=t:get_error();
e:event("bind-failure",{error=o,text=t,type=a});
end
end);
end
e:hook("stream-features",o,200);
return true;
end
end)
package.preload['verse.plugins.session']=(function(...)
local a=require"verse";
local t="urn:ietf:params:xml:ns:xmpp-session";
function a.plugins.session(e)
local function n(o)
local o=o:get_child("session",t);
if o and not o:get_child("optional")then
local function i(o)
e:debug("Establishing Session...");
e:send_iq(a.iq({type="set"}):tag("session",{xmlns=t}),
function(t)
if t.attr.type=="result"then
e:event("session-success");
elseif t.attr.type=="error"then
local a=t:child_with_name("error");
local t,o,a=t:get_error();
e:event("session-failure",{error=o,text=a,type=t});
end
end);
return true;
end
e:hook("bind-success",i);
end
end
e:hook("stream-features",n);
return true;
end
end)
package.preload['verse.plugins.legacy']=(function(...)
local o=require"verse";
local n=require"util.uuid".generate;
local a="jabber:iq:auth";
function o.plugins.legacy(e)
function handle_auth_form(t)
local i=t:get_child("query",a);
if t.attr.type~="result"or not i then
local a,o,t=t:get_error();
e:debug("warn","%s %s: %s",a,o,t);
end
local t={
username=e.username;
password=e.password;
resource=e.resource or n();
digest=false,sequence=false,token=false;
};
local a=o.iq({to=e.host,type="set"})
:tag("query",{xmlns=a});
if#i>0 then
for o in i:childtags()do
local o=o.name;
local i=t[o];
if i then
a:tag(o):text(t[o]):up();
elseif i==nil then
local t="feature-not-implemented";
e:event("authentication-failure",{condition=t});
return false;
end
end
else
for t,e in pairs(t)do
if e then
a:tag(t):text(e):up();
end
end
end
e:send_iq(a,function(a)
if a.attr.type=="result"then
e.resource=t.resource;
e.jid=t.username.."@"..e.host.."/"..t.resource;
e:event("authentication-success");
e:event("bind-success",e.jid);
else
local a,t,a=a:get_error();
e:event("authentication-failure",{condition=t});
end
end);
end
function handle_opened(t)
if not t.version then
e:send_iq(o.iq({type="get"})
:tag("query",{xmlns="jabber:iq:auth"})
:tag("username"):text(e.username),
handle_auth_form);
end
end
e:hook("opened",handle_opened);
end
end)
package.preload['verse.plugins.compression']=(function(...)
local a=require"verse";
local e=require"zlib";
local t="http://jabber.org/features/compress"
local t="http://jabber.org/protocol/compress"
local o="http://etherx.jabber.org/streams";
local i=9;
local function l(o)
local i,e=pcall(e.deflate,i);
if i==false then
local t=a.stanza("failure",{xmlns=t}):tag("setup-failed");
o:send(t);
o:error("Failed to create zlib.deflate filter: %s",tostring(e));
return
end
return e
end
local function d(o)
local i,e=pcall(e.inflate);
if i==false then
local t=a.stanza("failure",{xmlns=t}):tag("setup-failed");
o:send(t);
o:error("Failed to create zlib.inflate filter: %s",tostring(e));
return
end
return e
end
local function h(e,o)
function e:send(i)
local i,o,n=pcall(o,tostring(i),'sync');
if i==false then
e:close({
condition="undefined-condition";
text=o;
extra=a.stanza("failure",{xmlns=t}):tag("processing-failed");
});
e:warn("Compressed send failed: %s",tostring(o));
return;
end
e.conn:write(o);
end;
end
local function r(e,i)
local s=e.data
e.data=function(n,o)
e:debug("Decompressing data...");
local i,o,h=pcall(i,o);
if i==false then
e:close({
condition="undefined-condition";
text=o;
extra=a.stanza("failure",{xmlns=t}):tag("processing-failed");
});
stream:warn("%s",tostring(o));
return;
end
return s(n,o);
end;
end
function a.plugins.compression(e)
local function n(o)
if not e.compressed then
local o=o:child_with_name("compression");
if o then
for o in o:children()do
local o=o[1]
if o=="zlib"then
e:send(a.stanza("compress",{xmlns=t}):tag("method"):text("zlib"))
e:debug("Enabled compression using zlib.")
return true;
end
end
session:debug("Remote server supports no compression algorithm we support.")
end
end
end
local function i(o)
if o.name=="compressed"then
e:debug("Activating compression...")
local t=l(e);
if not t then return end
local a=d(e);
if not a then return end
h(e,t);
r(e,a);
e.compressed=true;
e:reopen();
elseif o.name=="failure"then
e:warn("Failed to establish compression");
end
end
e:hook("stream-features",n,250);
e:hook("stream/"..t,i);
end
end)
package.preload['verse.plugins.smacks']=(function(...)
local n=require"verse";
local h=socket.gettime;
local i="urn:xmpp:sm:2";
function n.plugins.smacks(e)
local t={};
local a=0;
local r=h();
local o;
local s=0;
local function d(t)
if t.attr.xmlns=="jabber:client"or not t.attr.xmlns then
s=s+1;
e:debug("Increasing handled stanzas to %d for %s",s,t:top_tag());
end
end
function outgoing_stanza(a)
if a.name and not a.attr.xmlns then
t[#t+1]=tostring(a);
r=h();
if not o then
o=true;
e:debug("Waiting to send ack request...");
n.add_task(1,function()
if#t==0 then
o=false;
return;
end
local a=h()-r;
if a<1 and#t<10 then
return 1-a;
end
e:debug("Time up, sending <r>...");
o=false;
e:send(n.stanza("r",{xmlns=i}));
end);
end
end
end
local function h()
e:debug("smacks: connection lost");
e.stream_management_supported=nil;
if e.resumption_token then
e:debug("smacks: have resumption token, reconnecting in 1s...");
e.authenticated=nil;
n.add_task(1,function()
e:connect(e.connect_host or e.host,e.connect_port or 5222);
end);
return true;
end
end
local function r()
e.resumption_token=nil;
e:unhook("disconnected",h);
end
local function l(o)
if o.name=="r"then
e:debug("Ack requested... acking %d handled stanzas",s);
e:send(n.stanza("a",{xmlns=i,h=tostring(s)}));
elseif o.name=="a"then
local o=tonumber(o.attr.h);
if o>a then
local i=#t;
for a=a+1,o do
table.remove(t,1);
end
e:debug("Received ack: New ack: "..o.." Last ack: "..a.." Unacked stanzas now: "..#t.." (was "..i..")");
a=o;
else
e:warn("Received bad ack for "..o.." when last ack was "..a);
end
elseif o.name=="enabled"then
if o.attr.id then
e.resumption_token=o.attr.id;
e:hook("closed",r,100);
e:hook("disconnected",h,100);
end
elseif o.name=="resumed"then
local o=tonumber(o.attr.h);
if o>a then
local i=#t;
for a=a+1,o do
table.remove(t,1);
end
e:debug("Received ack: New ack: "..o.." Last ack: "..a.." Unacked stanzas now: "..#t.." (was "..i..")");
a=o;
end
for a=1,#t do
e:send(t[a]);
end
t={};
e:debug("Resumed successfully");
e:event("resumed");
else
e:warn("Don't know how to handle "..i.."/"..o.name);
end
end
local function t()
if not e.smacks then
e:debug("smacks: sending enable");
e:send(n.stanza("enable",{xmlns=i,resume="true"}));
e.smacks=true;
e:hook("stanza",d);
e:hook("outgoing",outgoing_stanza);
end
end
local function o(a)
if a:get_child("sm",i)then
e.stream_management_supported=true;
if e.smacks and e.bound then
e:debug("Resuming stream with %d handled stanzas",s);
e:send(n.stanza("resume",{xmlns=i,
h=s,previd=e.resumption_token}));
return true;
else
e:hook("bind-success",t,1);
end
end
end
e:hook("stream-features",o,250);
e:hook("stream/"..i,l);
end
end)
package.preload['verse.plugins.keepalive']=(function(...)
local t=require"verse";
function t.plugins.keepalive(e)
e.keepalive_timeout=e.keepalive_timeout or 300;
t.add_task(e.keepalive_timeout,function()
e.conn:write(" ");
return e.keepalive_timeout;
end);
end
end)
package.preload['verse.plugins.disco']=(function(...)
local a=require"verse";
local r=require("mime").b64;
local h=require("util.sha1").sha1;
local s="http://jabber.org/protocol/caps";
local e="http://jabber.org/protocol/disco";
local i=e.."#info";
local n=e.."#items";
function a.plugins.disco(e)
e:add_plugin("presence");
local o={
__index=function(a,e)
local t={identities={},features={}};
if e=="identities"or e=="features"then
return a[false][e]
end
a[e]=t;
return t;
end,
};
local t={
__index=function(t,a)
local e={};
t[a]=e;
return e;
end,
};
e.disco={
cache={},
info=setmetatable({
[false]={
identities={
{category='client',type='pc',name='Verse'},
},
features={
[s]=true,
[i]=true,
[n]=true,
},
},
},o);
items=setmetatable({[false]={}},t);
};
e.caps={}
e.caps.node='http://code.matthewwild.co.uk/verse/'
local function d(t,e)
if t.category<e.category then
return true;
elseif e.category<t.category then
return false;
end
if t.type<e.type then
return true;
elseif e.type<t.type then
return false;
end
if(not t['xml:lang']and e['xml:lang'])or
(e['xml:lang']and t['xml:lang']<e['xml:lang'])then
return true
end
return false
end
local function l(e,t)
return e.var<t.var
end
local function u(t)
local o=e.disco.info[t or false].identities;
table.sort(o,d)
local a={};
for e in pairs(e.disco.info[t or false].features)do
a[#a+1]={var=e};
end
table.sort(a,l)
local e={};
for a,t in pairs(o)do
e[#e+1]=table.concat({
t.category,t.type or'',
t['xml:lang']or'',t.name or''
},'/');
end
for a,t in pairs(a)do
e[#e+1]=t.var
end
e[#e+1]='';
e=table.concat(e,'<');
return(r(h(e)))
end
setmetatable(e.caps,{
__call=function(...)
local t=u()
e.caps.hash=t;
return a.stanza('c',{
xmlns=s,
hash='sha-1',
node=e.caps.node,
ver=t
})
end
})
function e:set_identity(a,t)
self.disco.info[t or false].identities={a};
e:resend_presence();
end
function e:add_identity(a,t)
local t=self.disco.info[t or false].identities;
t[#t+1]=a;
e:resend_presence();
end
function e:add_disco_feature(t,a)
local t=t.var or t;
self.disco.info[a or false].features[t]=true;
e:resend_presence();
end
function e:remove_disco_feature(t,a)
local t=t.var or t;
self.disco.info[a or false].features[t]=nil;
e:resend_presence();
end
function e:add_disco_item(t,e)
local e=self.disco.items[e or false];
e[#e+1]=t;
end
function e:remove_disco_item(a,e)
local e=self.disco.items[e or false];
for t=#e,1,-1 do
if e[t]==a then
table.remove(e,t);
end
end
end
function e:jid_has_identity(t,e,a)
local o=self.disco.cache[t];
if not o then
return nil,"no-cache";
end
local t=self.disco.cache[t].identities;
if a then
return t[e.."/"..a]or false;
end
for t in pairs(t)do
if t:match("^(.*)/")==e then
return true;
end
end
end
function e:jid_supports(e,t)
local e=self.disco.cache[e];
if not e or not e.features then
return nil,"no-cache";
end
return e.features[t]or false;
end
function e:get_local_services(a,o)
local e=self.disco.cache[self.host];
if not(e)or not(e.items)then
return nil,"no-cache";
end
local t={};
for i,e in ipairs(e.items)do
if self:jid_has_identity(e.jid,a,o)then
table.insert(t,e.jid);
end
end
return t;
end
function e:disco_local_services(a)
self:disco_items(self.host,nil,function(t)
if not t then
return a({});
end
local e=0;
local function o()
e=e-1;
if e==0 then
return a(t);
end
end
for a,t in ipairs(t)do
if t.jid then
e=e+1;
self:disco_info(t.jid,nil,o);
end
end
if e==0 then
return a(t);
end
end);
end
function e:disco_info(e,t,s)
local a=a.iq({to=e,type="get"})
:tag("query",{xmlns=i,node=t});
self:send_iq(a,function(n)
if n.attr.type=="error"then
return s(nil,n:get_error());
end
local o,a={},{};
for e in n:get_child("query",i):childtags()do
if e.name=="identity"then
o[e.attr.category.."/"..e.attr.type]=e.attr.name or true;
elseif e.name=="feature"then
a[e.attr.var]=true;
end
end
if not self.disco.cache[e]then
self.disco.cache[e]={nodes={}};
end
if t then
if not self.disco.cache[e].nodes[t]then
self.disco.cache[e].nodes[t]={nodes={}};
end
self.disco.cache[e].nodes[t].identities=o;
self.disco.cache[e].nodes[t].features=a;
else
self.disco.cache[e].identities=o;
self.disco.cache[e].features=a;
end
return s(self.disco.cache[e]);
end);
end
function e:disco_items(t,o,i)
local a=a.iq({to=t,type="get"})
:tag("query",{xmlns=n,node=o});
self:send_iq(a,function(e)
if e.attr.type=="error"then
return i(nil,e:get_error());
end
local a={};
for e in e:get_child("query",n):childtags()do
if e.name=="item"then
table.insert(a,{
name=e.attr.name;
jid=e.attr.jid;
node=e.attr.node;
});
end
end
if not self.disco.cache[t]then
self.disco.cache[t]={nodes={}};
end
if o then
if not self.disco.cache[t].nodes[o]then
self.disco.cache[t].nodes[o]={nodes={}};
end
self.disco.cache[t].nodes[o].items=a;
else
self.disco.cache[t].items=a;
end
return i(a);
end);
end
e:hook("iq/"..i,function(n)
local t=n.tags[1];
if n.attr.type=='get'and t.name=="query"then
local t=t.attr.node;
local o=e.disco.info[t or false];
if t and t==e.caps.node.."#"..e.caps.hash then
o=e.disco.info[false];
end
local s,o=o.identities,o.features
local t=a.reply(n):tag("query",{
xmlns=i,
node=t,
});
for a,e in pairs(s)do
t:tag('identity',e):up()
end
for a in pairs(o)do
t:tag('feature',{var=a}):up()
end
e:send(t);
return true
end
end);
e:hook("iq/"..n,function(t)
local o=t.tags[1];
if t.attr.type=='get'and o.name=="query"then
local i=e.disco.items[o.attr.node or false];
local t=a.reply(t):tag('query',{
xmlns=n,
node=o.attr.node
})
for a=1,#i do
t:tag('item',i[a]):up()
end
e:send(t);
return true
end
end);
local t;
e:hook("ready",function()
if t then return;end
t=true;
e:disco_local_services(function(t)
for a,t in ipairs(t)do
local a=e.disco.cache[t.jid];
if a then
for a in pairs(a.identities)do
local a,o=a:match("^(.*)/(.*)$");
e:event("disco/service-discovered/"..a,{
type=o,jid=t.jid;
});
end
end
end
e:event("ready");
end);
return true;
end,50);
e:hook("presence-out",function(t)
if not t:get_child("c",s)then
t:reset():add_child(e:caps()):reset();
end
end,10);
end
end)
package.preload['verse.plugins.version']=(function(...)
local o=require"verse";
local t="jabber:iq:version";
local function a(t,e)
t.name=e.name;
t.version=e.version;
t.platform=e.platform;
end
function o.plugins.version(e)
e.version={set=a};
e:hook("iq/"..t,function(a)
if a.attr.type~="get"then return;end
local t=o.reply(a)
:tag("query",{xmlns=t});
if e.version.name then
t:tag("name"):text(tostring(e.version.name)):up();
end
if e.version.version then
t:tag("version"):text(tostring(e.version.version)):up()
end
if e.version.platform then
t:tag("os"):text(e.version.platform);
end
e:send(t);
return true;
end);
function e:query_version(i,a)
a=a or function(t)return e:event("version/response",t);end
e:send_iq(o.iq({type="get",to=i})
:tag("query",{xmlns=t}),
function(o)
if o.attr.type=="result"then
local e=o:get_child("query",t);
local t=e and e:get_child_text("name");
local o=e and e:get_child_text("version");
local e=e and e:get_child_text("os");
a({
name=t;
version=o;
platform=e;
});
else
local t,e,o=o:get_error();
a({
error=true;
condition=e;
text=o;
type=t;
});
end
end);
end
return true;
end
end)
package.preload['verse.plugins.ping']=(function(...)
local a=require"verse";
local o="urn:xmpp:ping";
function a.plugins.ping(e)
function e:ping(t,i)
local n=socket.gettime();
e:send_iq(a.iq{to=t,type="get"}:tag("ping",{xmlns=o}),
function(e)
if e.attr.type=="error"then
local a,e,o=e:get_error();
if e~="service-unavailable"and e~="feature-not-implemented"then
i(nil,t,{type=a,condition=e,text=o});
return;
end
end
i(socket.gettime()-n,t);
end);
end
e:hook("iq/"..o,function(t)
return e:send(a.reply(t));
end);
return true;
end
end)
package.preload['verse.plugins.uptime']=(function(...)
local o=require"verse";
local a="jabber:iq:last";
local function i(t,e)
t.starttime=e.starttime;
end
function o.plugins.uptime(e)
e.uptime={set=i};
e:hook("iq/"..a,function(t)
if t.attr.type~="get"then return;end
local t=o.reply(t)
:tag("query",{seconds=tostring(os.difftime(os.time(),e.uptime.starttime)),xmlns=a});
e:send(t);
return true;
end);
function e:query_uptime(i,t)
t=t or function(t)return e:event("uptime/response",t);end
e:send_iq(o.iq({type="get",to=i})
:tag("query",{xmlns=a}),
function(e)
local a=e:get_child("query",a);
if e.attr.type=="result"then
local e=tonumber(a.attr.seconds);
t({
seconds=e or nil;
});
else
local a,e,o=e:get_error();
t({
error=true;
condition=e;
text=o;
type=a;
});
end
end);
end
return true;
end
end)
package.preload['verse.plugins.blocking']=(function(...)
local o=require"verse";
local a="urn:xmpp:blocking";
function o.plugins.blocking(e)
e.blocking={};
function e.blocking:block_jid(i,t)
e:send_iq(o.iq{type="set"}
:tag("block",{xmlns=a})
:tag("item",{jid=i})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:unblock_jid(i,t)
e:send_iq(o.iq{type="set"}
:tag("unblock",{xmlns=a})
:tag("item",{jid=i})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:unblock_all_jids(t)
e:send_iq(o.iq{type="set"}
:tag("unblock",{xmlns=a})
,function()return t and t(true);end
,function()return t and t(false);end
);
end
function e.blocking:get_blocked_jids(t)
e:send_iq(o.iq{type="get"}
:tag("blocklist",{xmlns=a})
,function(e)
local a=e:get_child("blocklist",a);
if not a then return t and t(false);end
local e={};
for t in a:childtags()do
e[#e+1]=t.attr.jid;
end
return t and t(e);
end
,function(e)return t and t(false);end
);
end
end
end)
package.preload['verse.plugins.jingle']=(function(...)
local a=require"verse";
local e=require"util.sha1".sha1;
local e=require"util.timer";
local n=require"util.uuid".generate;
local i="urn:xmpp:jingle:1";
local o="urn:xmpp:jingle:errors:1";
local t={};
t.__index=t;
local e={};
local e={};
function a.plugins.jingle(e)
e:hook("ready",function()
e:add_disco_feature(i);
end,10);
function e:jingle(o)
return a.eventable(setmetatable(base or{
role="initiator";
peer=o;
sid=n();
stream=e;
},t));
end
function e:register_jingle_transport(e)
end
function e:register_jingle_content_type(e)
end
local function u(n)
local r=n:get_child("jingle",i);
local s=r.attr.sid;
local h=r.attr.action;
local s=e:event("jingle/"..s,n);
if s==true then
e:send(a.reply(n));
return true;
end
if h~="session-initiate"then
local t=a.error_reply(n,"cancel","item-not-found")
:tag("unknown-session",{xmlns=o}):up();
e:send(t);
return;
end
local l=r.attr.sid;
local o=a.eventable{
role="receiver";
peer=n.attr.from;
sid=l;
stream=e;
};
setmetatable(o,t);
local d;
local h,s;
for t in r:childtags()do
if t.name=="content"and t.attr.xmlns==i then
local a=t:child_with_name("description");
local i=a.attr.xmlns;
if i then
local e=e:event("jingle/content/"..i,o,a);
if e then
h=e;
end
end
local a=t:child_with_name("transport");
local i=a.attr.xmlns;
s=e:event("jingle/transport/"..i,o,a);
if h and s then
d=t;
break;
end
end
end
if not h then
e:send(a.error_reply(n,"cancel","feature-not-implemented","The specified content is not supported"));
return true;
end
if not s then
e:send(a.error_reply(n,"cancel","feature-not-implemented","The specified transport is not supported"));
return true;
end
e:send(a.reply(n));
o.content_tag=d;
o.creator,o.name=d.attr.creator,d.attr.name;
o.content,o.transport=h,s;
function o:decline()
end
e:hook("jingle/"..l,function(e)
if e.attr.from~=o.peer then
return false;
end
local e=e:get_child("jingle",i);
return o:handle_command(e);
end);
e:event("jingle",o);
return true;
end
function t:handle_command(a)
local t=a.attr.action;
e:debug("Handling Jingle command: %s",t);
if t=="session-terminate"then
self:destroy();
elseif t=="session-accept"then
self:handle_accepted(a);
elseif t=="transport-info"then
e:debug("Handling transport-info");
self.transport:info_received(a);
elseif t=="transport-replace"then
e:error("Peer wanted to swap transport, not implemented");
else
e:warn("Unhandled Jingle command: %s",t);
return nil;
end
return true;
end
function t:send_command(t,o,e)
local t=a.iq({to=self.peer,type="set"})
:tag("jingle",{
xmlns=i,
sid=self.sid,
action=t,
initiator=self.role=="initiator"and self.stream.jid or nil,
responder=self.role=="responder"and self.jid or nil,
}):add_child(o);
if not e then
self.stream:send(t);
else
self.stream:send_iq(t,e);
end
end
function t:accept(t)
local a=a.iq({to=self.peer,type="set"})
:tag("jingle",{
xmlns=i,
sid=self.sid,
action="session-accept",
responder=e.jid,
})
:tag("content",{creator=self.creator,name=self.name});
local o=self.content:generate_accept(self.content_tag:child_with_name("description"),t);
a:add_child(o);
local t=self.transport:generate_accept(self.content_tag:child_with_name("transport"),t);
a:add_child(t);
local t=self;
e:send_iq(a,function(a)
if a.attr.type=="error"then
local a,t,a=a:get_error();
e:error("session-accept rejected: %s",t);
return false;
end
t.transport:connect(function(a)
e:warn("CONNECTED (receiver)!!!");
t.state="active";
t:event("connected",a);
end);
end);
end
e:hook("iq/"..i,u);
return true;
end
function t:offer(t,o)
local e=a.iq({to=self.peer,type="set"})
:tag("jingle",{xmlns=i,action="session-initiate",
initiator=self.stream.jid,sid=self.sid});
e:tag("content",{creator=self.role,name=t});
local t=self.stream:event("jingle/describe/"..t,o);
if not t then
return false,"Unknown content type";
end
e:add_child(t);
local t=self.stream:event("jingle/transport/".."urn:xmpp:jingle:transports:s5b:1",self);
self.transport=t;
e:add_child(t:generate_initiate());
self.stream:debug("Hooking %s","jingle/"..self.sid);
self.stream:hook("jingle/"..self.sid,function(e)
if e.attr.from~=self.peer then
return false;
end
local e=e:get_child("jingle",i);
return self:handle_command(e)
end);
self.stream:send_iq(e,function(e)
if e.attr.type=="error"then
self.state="terminated";
local t,a,e=e:get_error();
return self:event("error",{type=t,condition=a,text=e});
end
end);
self.state="pending";
end
function t:terminate(e)
local e=a.stanza("reason"):tag(e or"success");
self:send_command("session-terminate",e,function(e)
self.state="terminated";
self.transport:disconnect();
self:destroy();
end);
end
function t:destroy()
self:event("terminated");
self.stream:unhook("jingle/"..self.sid,self.handle_command);
end
function t:handle_accepted(e)
local e=e:child_with_name("transport");
self.transport:handle_accepted(e);
self.transport:connect(function(e)
self.stream:debug("CONNECTED (initiator)!")
self.state="active";
self:event("connected",e);
end);
end
function t:set_source(a,o)
local function t()
local e,i=a();
if e and e~=""then
self.transport.conn:send(e);
elseif e==""then
return t();
elseif e==nil then
if o then
self:terminate();
end
self.transport.conn:unhook("drained",t);
a=nil;
end
end
self.transport.conn:hook("drained",t);
t();
end
function t:set_sink(t)
self.transport.conn:hook("incoming-raw",t);
self.transport.conn:hook("disconnected",function(e)
self.stream:debug("Closing sink...");
local e=e.reason;
if e=="closed"then e=nil;end
t(nil,e);
end);
end
end)
package.preload['verse.plugins.jingle_ft']=(function(...)
local o=require"verse";
local s=require"ltn12";
local h=package.config:sub(1,1);
local a="urn:xmpp:jingle:apps:file-transfer:1";
local i="http://jabber.org/protocol/si/profile/file-transfer";
function o.plugins.jingle_ft(t)
t:hook("ready",function()
t:add_disco_feature(a);
end,10);
local n={type="file"};
function n:generate_accept(t,e)
if e and e.save_file then
self.jingle:hook("connected",function()
local e=s.sink.file(io.open(e.save_file,"w+"));
self.jingle:set_sink(e);
end);
end
return t;
end
local n={__index=n};
t:hook("jingle/content/"..a,function(t,e)
local e=e:get_child("offer"):get_child("file",i);
local e={
name=e.attr.name;
size=tonumber(e.attr.size);
};
return setmetatable({jingle=t,file=e},n);
end);
t:hook("jingle/describe/file",function(e)
local t;
if e.timestamp then
t=q.date("!%Y-%m-%dT%H:%M:%SZ",e.timestamp);
end
return o.stanza("description",{xmlns=a})
:tag("offer")
:tag("file",{xmlns=i,
name=e.filename,
size=e.size,
date=t,
hash=e.hash,
})
:tag("desc"):text(e.description or"");
end);
function t:send_file(a,t)
local e,o=io.open(t);
if not e then return e,o;end
local o=e:seek("end",0);
e:seek("set",0);
local i=s.source.file(e);
local e=self:jingle(a);
e:offer("file",{
filename=t:match("[^"..h.."]+$");
size=o;
});
e:hook("connected",function()
e:set_source(i,true);
end);
return e;
end
end
end)
package.preload['verse.plugins.jingle_s5b']=(function(...)
local t=require"verse";
local o="urn:xmpp:jingle:transports:s5b:1";
local d="http://jabber.org/protocol/bytestreams";
local h=require"util.sha1".sha1;
local l=require"util.uuid".generate;
local function r(e,s)
local function i()
e:unhook("connected",i);
return true;
end
local function n(t)
e:unhook("incoming-raw",n);
if t:sub(1,2)~="\005\000"then
return e:event("error","connection-failure");
end
e:event("connected");
return true;
end
local function o(t)
e:unhook("incoming-raw",o);
if t~="\005\000"then
local a="version-mismatch";
if t:sub(1,1)=="\005"then
a="authentication-failure";
end
return e:event("error",a);
end
e:send(string.char(5,1,0,3,#s)..s.."\0\0");
e:hook("incoming-raw",n,100);
return true;
end
e:hook("connected",i,200);
e:hook("incoming-raw",o,100);
e:send("\005\001\000");
end
local function s(a,e,i)
local e=t.new(nil,{
streamhosts=e,
current_host=0;
});
local function t(o)
if o then
return a(nil,o.reason);
end
if e.current_host<#e.streamhosts then
e.current_host=e.current_host+1;
e:debug("Attempting to connect to "..e.streamhosts[e.current_host].host..":"..e.streamhosts[e.current_host].port.."...");
local a,t=e:connect(
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port
);
if not a then
e:debug("Error connecting to proxy (%s:%s): %s",
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port,
t
);
else
e:debug("Connecting...");
end
r(e,i);
return true;
end
e:unhook("disconnected",t);
return a(nil);
end
e:hook("disconnected",t,100);
e:hook("connected",function()
e:unhook("disconnected",t);
a(e.streamhosts[e.current_host],e);
end,100);
t();
return e;
end
function t.plugins.jingle_s5b(e)
e:hook("ready",function()
e:add_disco_feature(o);
end,10);
local a={};
function a:generate_initiate()
self.s5b_sid=l();
local i=t.stanza("transport",{xmlns=o,
mode="tcp",sid=self.s5b_sid});
local t=0;
for o,a in pairs(e.proxy65.available_streamhosts)do
t=t+1;
i:tag("candidate",{jid=o,host=a.host,
port=a.port,cid=o,priority=t,type="proxy"}):up();
end
e:debug("Have %d proxies",t)
return i;
end
function a:generate_accept(e)
local a={};
self.s5b_peer_candidates=a;
self.s5b_mode=e.attr.mode or"tcp";
self.s5b_sid=e.attr.sid or self.jingle.sid;
for e in e:childtags()do
a[e.attr.cid]={
type=e.attr.type;
jid=e.attr.jid;
host=e.attr.host;
port=tonumber(e.attr.port)or 0;
priority=tonumber(e.attr.priority)or 0;
cid=e.attr.cid;
};
end
local e=t.stanza("transport",{xmlns=o});
return e;
end
function a:connect(i)
e:warn("Connecting!");
local a={};
for t,e in pairs(self.s5b_peer_candidates or{})do
a[#a+1]=e;
end
if#a>0 then
self.connecting_peer_candidates=true;
local function n(e,a)
self.jingle:send_command("transport-info",t.stanza("content",{creator=self.creator,name=self.name})
:tag("transport",{xmlns=o,sid=self.s5b_sid})
:tag("candidate-used",{cid=e.cid}));
self.onconnect_callback=i;
self.conn=a;
end
local e=h(self.s5b_sid..self.peer..e.jid,true);
s(n,a,e);
else
e:warn("Actually, I'm going to wait for my peer to tell me its streamhost...");
self.onconnect_callback=i;
end
end
function a:info_received(a)
e:warn("Info received");
local n=a:child_with_name("content");
local i=n:child_with_name("transport");
if i:get_child("candidate-used")and not self.connecting_peer_candidates then
local a=i:child_with_name("candidate-used");
if a then
local function r(i,e)
if self.jingle.role=="initiator"then
self.jingle.stream:send_iq(t.iq({to=i.jid,type="set"})
:tag("query",{xmlns=d,sid=self.s5b_sid})
:tag("activate"):text(self.jingle.peer),function(i)
if i.attr.type=="result"then
self.jingle:send_command("transport-info",t.stanza("content",n.attr)
:tag("transport",{xmlns=o,sid=self.s5b_sid})
:tag("activated",{cid=a.attr.cid}));
self.conn=e;
self.onconnect_callback(e);
else
self.jingle.stream:error("Failed to activate bytestream");
end
end);
end
end
self.jingle.stream:debug("CID: %s",self.jingle.stream.proxy65.available_streamhosts[a.attr.cid]);
local t={
self.jingle.stream.proxy65.available_streamhosts[a.attr.cid];
};
local e=h(self.s5b_sid..e.jid..self.peer,true);
s(r,t,e);
end
elseif i:get_child("activated")then
self.onconnect_callback(self.conn);
end
end
function a:disconnect()
if self.conn then
self.conn:close();
end
end
function a:handle_accepted(e)
end
local t={__index=a};
e:hook("jingle/transport/"..o,function(e)
return setmetatable({
role=e.role,
peer=e.peer,
stream=e.stream,
jingle=e,
},t);
end);
end
end)
package.preload['verse.plugins.proxy65']=(function(...)
local e=require"util.events";
local r=require"util.uuid";
local h=require"util.sha1";
local i={};
i.__index=i;
local o="http://jabber.org/protocol/bytestreams";
local n;
function verse.plugins.proxy65(t)
t.proxy65=setmetatable({stream=t},i);
t.proxy65.available_streamhosts={};
local e=0;
t:hook("disco/service-discovered/proxy",function(a)
if a.type=="bytestreams"then
e=e+1;
t:send_iq(verse.iq({to=a.jid,type="get"})
:tag("query",{xmlns=o}),function(a)
e=e-1;
if a.attr.type=="result"then
local e=a:get_child("query",o)
:get_child("streamhost").attr;
t.proxy65.available_streamhosts[e.jid]={
jid=e.jid;
host=e.host;
port=tonumber(e.port);
};
end
if e==0 then
t:event("proxy65/discovered-proxies",t.proxy65.available_streamhosts);
end
end);
end
end);
t:hook("iq/"..o,function(a)
local e=verse.new(nil,{
initiator_jid=a.attr.from,
streamhosts={},
current_host=0;
});
for t in a.tags[1]:childtags()do
if t.name=="streamhost"then
table.insert(e.streamhosts,t.attr);
end
end
local function o()
if e.current_host<#e.streamhosts then
e.current_host=e.current_host+1;
e:connect(
e.streamhosts[e.current_host].host,
e.streamhosts[e.current_host].port
);
n(t,e,a.tags[1].attr.sid,a.attr.from,t.jid);
return true;
end
e:unhook("disconnected",o);
t:send(verse.error_reply(a,"cancel","item-not-found"));
end
function e:accept()
e:hook("disconnected",o,100);
e:hook("connected",function()
e:unhook("disconnected",o);
local e=verse.reply(a)
:tag("query",a.tags[1].attr)
:tag("streamhost-used",{jid=e.streamhosts[e.current_host].jid});
t:send(e);
end,100);
o();
end
function e:refuse()
end
t:event("proxy65/request",e);
end);
end
function i:new(t,s)
local e=verse.new(nil,{
target_jid=t;
bytestream_sid=r.generate();
});
local a=verse.iq{type="set",to=t}
:tag("query",{xmlns=o,mode="tcp",sid=e.bytestream_sid});
for t,e in ipairs(s or self.proxies)do
a:tag("streamhost",e):up();
end
self.stream:send_iq(a,function(a)
if a.attr.type=="error"then
local o,t,a=a:get_error();
e:event("connection-failed",{conn=e,type=o,condition=t,text=a});
else
local a=a.tags[1]:get_child("streamhost-used");
if not a then
end
e.streamhost_jid=a.attr.jid;
local i,a;
for o,t in ipairs(s or self.proxies)do
if t.jid==e.streamhost_jid then
i,a=t.host,t.port;
break;
end
end
if not(i and a)then
end
e:connect(i,a);
local function a()
e:unhook("connected",a);
local t=verse.iq{to=e.streamhost_jid,type="set"}
:tag("query",{xmlns=o,sid=e.bytestream_sid})
:tag("activate"):text(t);
self.stream:send_iq(t,function(t)
if t.attr.type=="result"then
e:event("connected",e);
else
end
end);
return true;
end
e:hook("connected",a,100);
n(self.stream,e,e.bytestream_sid,self.stream.jid,t);
end
end);
return e;
end
function n(i,e,o,a,t)
local a=h.sha1(o..a..t);
local function t()
e:unhook("connected",t);
return true;
end
local function o(t)
e:unhook("incoming-raw",o);
if t:sub(1,2)~="\005\000"then
return e:event("error","connection-failure");
end
e:event("connected");
return true;
end
local function i(n)
e:unhook("incoming-raw",i);
if n~="\005\000"then
local t="version-mismatch";
if n:sub(1,1)=="\005"then
t="authentication-failure";
end
return e:event("error",t);
end
e:send(string.char(5,1,0,3,#a)..a.."\0\0");
e:hook("incoming-raw",o,100);
return true;
end
e:hook("connected",t,200);
e:hook("incoming-raw",i,100);
e:send("\005\001\000");
end
end)
package.preload['verse.plugins.jingle_ibb']=(function(...)
local e=require"verse";
local i=require"util.encodings".base64;
local s=require"util.uuid".generate;
local n="urn:xmpp:jingle:transports:ibb:1";
local o="http://jabber.org/protocol/ibb";
assert(i.encode("This is a test.")=="VGhpcyBpcyBhIHRlc3Qu","Base64 encoding failed");
assert(i.decode("VGhpcyBpcyBhIHRlc3Qu")=="This is a test.","Base64 decoding failed");
local t=table.concat
local a={};
local h={__index=a};
local function r(t)
local t=setmetatable({stream=t},h)
t=e.eventable(t);
return t;
end
function a:initiate(t,e,a)
self.block=2048;
self.stanza=a or'iq';
self.peer=t;
self.sid=e or tostring(self):match("%x+$");
self.iseq=0;
self.oseq=0;
local e=function(e)
return self:feed(e)
end
self.feeder=e;
print("Hooking incomming IQs");
local t=self.stream;
t:hook("iq/"..o,e)
if a=="message"then
t:hook("message",e)
end
end
function a:open(t)
self.stream:send_iq(e.iq{to=self.peer,type="set"}
:tag("open",{
xmlns=o,
["block-size"]=self.block,
sid=self.sid,
stanza=self.stanza
})
,function(e)
if t then
if e.attr.type~="error"then
t(true)
else
t(false,e:get_error())
end
end
end);
end
function a:send(n)
local a=self.stanza;
local t;
if a=="iq"then
t=e.iq{type="set",to=self.peer}
elseif a=="message"then
t=e.message{to=self.peer}
end
local e=self.oseq;
self.oseq=e+1;
t:tag("data",{xmlns=o,sid=self.sid,seq=e})
:text(i.encode(n));
if a=="iq"then
self.stream:send_iq(t,function(e)
self:event(e.attr.type=="result"and"drained"or"error");
end)
else
stream:send(t)
self:event("drained");
end
end
function a:feed(t)
if t.attr.from~=self.peer then return end
local a=t[1];
if a.attr.sid~=self.sid then return end
local n;
if a.name=="open"then
self:event("connected");
self.stream:send(e.reply(t))
return true
elseif a.name=="data"then
local o=t:get_child_text("data",o);
local a=tonumber(a.attr.seq);
local n=self.iseq;
if o and a then
if a~=n then
self.stream:send(e.error_reply(t,"cancel","not-acceptable","Wrong sequence. Packet lost?"))
self:close();
self:event("error");
return true;
end
self.iseq=a+1;
local a=i.decode(o);
if self.stanza=="iq"then
self.stream:send(e.reply(t))
end
self:event("incoming-raw",a);
return true;
end
elseif a.name=="close"then
self.stream:send(e.reply(t))
self:close();
return true
end
end
function a:close()
self.stream:unhook("iq/"..o,self.feeder)
self:event("disconnected");
end
function e.plugins.jingle_ibb(a)
a:hook("ready",function()
a:add_disco_feature(n);
end,10);
local t={};
function t:_setup()
local e=r(self.stream);
e.sid=self.sid or e.sid;
e.stanza=self.stanza or e.stanza;
e.block=self.block or e.block;
e:initiate(self.peer,self.sid,self.stanza);
self.conn=e;
end
function t:generate_initiate()
print("ibb:generate_initiate() as "..self.role);
local t=s();
self.sid=t;
self.stanza='iq';
self.block=2048;
local e=e.stanza("transport",{xmlns=n,
sid=self.sid,stanza=self.stanza,["block-size"]=self.block});
return e;
end
function t:generate_accept(t)
print("ibb:generate_accept() as "..self.role);
local e=t.attr;
self.sid=e.sid or self.sid;
self.stanza=e.stanza or self.stanza;
self.block=e["block-size"]or self.block;
self:_setup();
return t;
end
function t:connect(t)
if not self.conn then
self:_setup();
end
local e=self.conn;
print("ibb:connect() as "..self.role);
if self.role=="initiator"then
e:open(function(a,...)
assert(a,table.concat({...},", "));
t(e);
end);
else
t(e);
end
end
function t:info_received(e)
print("ibb:info_received()");
end
function t:disconnect()
if self.conn then
self.conn:close()
end
end
function t:handle_accepted(e)end
local t={__index=t};
a:hook("jingle/transport/"..n,function(e)
return setmetatable({
role=e.role,
peer=e.peer,
stream=e.stream,
jingle=e,
},t);
end);
end
end)
package.preload['verse.plugins.pubsub']=(function(...)
local n=require"verse";
local e=require"util.jid".bare;
local s=table.insert;
local o="http://jabber.org/protocol/pubsub";
local h="http://jabber.org/protocol/pubsub#owner";
local a="http://jabber.org/protocol/pubsub#event";
local e="http://jabber.org/protocol/pubsub#errors";
local e={};
local i={__index=e};
function n.plugins.pubsub(e)
e.pubsub=setmetatable({stream=e},i);
e:hook("message",function(t)
local o=t.attr.from;
for t in t:childtags("event",a)do
local t=t:get_child("items");
if t then
local a=t.attr.node;
for t in t:childtags("item")do
e:event("pubsub/event",{
from=o;
node=a;
item=t;
});
end
end
end
end);
return true;
end
function e:create(t,e,a)
return self:service(t):node(e):create(nil,a);
end
function e:subscribe(o,t,a,e)
return self:service(o):node(t):subscribe(a,nil,e);
end
function e:publish(i,o,a,e,t)
return self:service(i):node(o):publish(a,nil,e,t);
end
local a={};
local t={__index=a};
function e:service(e)
return setmetatable({stream=self.stream,service=e},t)
end
local function t(s,i,e,a,h,r,t)
local e=n.iq{type=s or"get",to=i}
:tag("pubsub",{xmlns=e or o})
if a then e:tag(a,{node=h,jid=r});end
if t then e:tag("item",{id=t~=true and t or nil});end
return e;
end
function a:subscriptions(e)
self.stream:send_iq(t(nil,self.service,nil,"subscriptions")
,e and function(t)
if t.attr.type=="result"then
local t=t:get_child("pubsub",o);
local t=t and t:get_child("subscriptions");
local a={};
if t then
for t in t:childtags("subscription")do
local e=self:node(t.attr.node)
e.subscription=t;
e.subscribed_jid=t.attr.jid;
s(a,e);
end
end
e(a);
else
e(false,t:get_error());
end
end or nil);
end
function a:affiliations(a)
self.stream:send_iq(t(nil,self.service,nil,"affiliations")
,a and function(e)
if e.attr.type=="result"then
local e=e:get_child("pubsub",o);
local e=e and e:get_child("affiliations")or{};
local t={};
if e then
for a in e:childtags("affiliation")do
local e=self:node(a.attr.node)
e.affiliation=a;
s(t,e);
end
end
a(t);
else
a(false,e:get_error());
end
end or nil);
end
function a:nodes(a)
self.stream:disco_items(self.service,nil,function(e,...)
if e then
for t=1,#e do
e[t]=self:node(e[t].node);
end
end
a(e,...)
end);
end
local e={};
local o={__index=e};
function a:node(e)
return setmetatable({stream=self.stream,service=self.service,node=e},o)
end
function i:__call(t,e)
local t=self:service(t);
return e and t:node(e)or t;
end
function e:hook(a,o)
self._hooks=self._hooks or setmetatable({},{__mode='kv'});
local function t(e)
if(not e.service or e.from==self.service)and e.node==self.node then
return a(e)
end
end
self._hooks[a]=t;
self.stream:hook("pubsub/event",t,o);
return t;
end
function e:unhook(e)
if e then
local e=self._hooks[e];
self.stream:unhook("pubsub/event",e);
elseif self._hooks then
for e in pairs(self._hooks)do
self.stream:unhook("pubsub/event",e);
end
end
end
function e:create(a,e)
if a~=nil then
error("Not implemented yet.");
else
self.stream:send_iq(t("set",self.service,nil,"create",self.node),e);
end
end
function e:configure(e,a)
if e~=nil then
error("Not implemented yet.");
end
self.stream:send_iq(t("set",self.service,nil,e==nil and"default"or"configure",self.node),a);
end
function e:publish(i,o,a,e)
if o~=nil then
error("Node configuration is not implemented yet.");
end
self.stream:send_iq(t("set",self.service,nil,"publish",self.node,nil,i or true)
:add_child(a)
,e);
end
function e:subscribe(e,o,a)
e=e or self.stream.jid;
if o~=nil then
error("Subscription configuration is not implemented yet.");
end
self.stream:send_iq(t("set",self.service,nil,"subscribe",self.node,e,id)
,a);
end
function e:subscription(e)
error("Not implemented yet.");
end
function e:affiliation(e)
error("Not implemented yet.");
end
function e:unsubscribe(e,a)
e=e or self.subscribed_jid or self.stream.jid;
self.stream:send_iq(t("set",self.service,nil,"unsubscribe",self.node,e)
,a);
end
function e:configure_subscription(e,e)
error("Not implemented yet.");
end
function e:items(a,e)
if a then
self.stream:send_iq(t("get",self.service,nil,"items",self.node)
,e);
else
self.stream:disco_items(self.service,self.node,e);
end
end
function e:item(a,e)
self.stream:send_iq(t("get",self.service,nil,"items",self.node,nil,a)
,e);
end
function e:retract(e,a)
self.stream:send_iq(t("set",self.service,nil,"retract",self.node,nil,e)
,a);
end
function e:purge(e,a)
assert(not e,"Not implemented yet.");
self.stream:send_iq(t("set",self.service,h,"purge",self.node)
,a);
end
function e:delete(a,e)
assert(not a,"Not implemented yet.");
self.stream:send_iq(t("set",self.service,h,"delete",self.node)
,e);
end
end)
package.preload['verse.plugins.pep']=(function(...)
local e=require"verse";
local t="http://jabber.org/protocol/pubsub";
local t=t.."#event";
function e.plugins.pep(e)
e:add_plugin("disco");
e:add_plugin("pubsub");
e.pep={};
e:hook("pubsub/event",function(t)
return e:event("pep/"..t.node,{from=t.from,item=t.item.tags[1]});
end);
function e:hook_pep(t,i,o)
local a=e.events._handlers["pep/"..t];
if not(a)or#a==0 then
e:add_disco_feature(t.."+notify");
end
e:hook("pep/"..t,i,o);
end
function e:unhook_pep(t,a)
e:unhook("pep/"..t,a);
local a=e.events._handlers["pep/"..t];
if not(a)or#a==0 then
e:remove_disco_feature(t.."+notify");
end
end
function e:publish_pep(t,a)
return e.pubsub:service(nil):node(a or t.attr.xmlns):publish(nil,nil,t)
end
end
end)
package.preload['verse.plugins.adhoc']=(function(...)
local o=require"verse";
local n=require"lib.adhoc";
local t="http://jabber.org/protocol/commands";
local d="jabber:x:data";
local a={};
a.__index=a;
local i={};
function o.plugins.adhoc(e)
e:add_plugin("disco");
e:add_disco_feature(t);
function e:query_commands(a,o)
e:disco_items(a,t,function(a)
e:debug("adhoc list returned")
local t={};
for o,a in ipairs(a)do
t[a.node]=a.name;
end
e:debug("adhoc calling callback")
return o(t);
end);
end
function e:execute_command(i,t,o)
local e=setmetatable({
stream=e,jid=i,
command=t,callback=o
},a);
return e:execute();
end
local function r(t,e)
if not(e)or e=="user"then return true;end
if type(e)=="function"then
return e(t);
end
end
function e:add_adhoc_command(o,a,h,s)
i[a]=n.new(o,a,h,s);
e:add_disco_item({jid=e.jid,node=a,name=o},t);
return i[a];
end
local function s(t)
local a=t.tags[1];
local a=a.attr.node;
local a=i[a];
if not a then return;end
if not r(t.attr.from,a.permission)then
e:send(o.error_reply(t,"auth","forbidden","You don't have permission to execute this command"):up()
:add_child(a:cmdtag("canceled")
:tag("note",{type="error"}):text("You don't have permission to execute this command")));
return true
end
return n.handle_cmd(a,{send=function(t)return e:send(t)end},t);
end
e:hook("iq/"..t,function(e)
local t=e.attr.type;
local a=e.tags[1].name;
if t=="set"and a=="command"then
return s(e);
end
end);
end
function a:_process_response(e)
if e.attr.type=="error"then
self.status="canceled";
self.callback(self,{});
return;
end
local e=e:get_child("command",t);
self.status=e.attr.status;
self.sessionid=e.attr.sessionid;
self.form=e:get_child("x",d);
self.note=e:get_child("note");
self.callback(self);
end
function a:execute()
local e=o.iq({to=self.jid,type="set"})
:tag("command",{xmlns=t,node=self.command});
self.stream:send_iq(e,function(e)
self:_process_response(e);
end);
end
function a:next(a)
local e=o.iq({to=self.jid,type="set"})
:tag("command",{
xmlns=t,
node=self.command,
sessionid=self.sessionid
});
if a then e:add_child(a);end
self.stream:send_iq(e,function(e)
self:_process_response(e);
end);
end
end)
package.preload['verse.plugins.presence']=(function(...)
local a=require"verse";
function a.plugins.presence(e)
e.last_presence=nil;
e:hook("presence-out",function(t)
if not t.attr.to then
e.last_presence=t;
end
end,1);
function e:resend_presence()
if last_presence then
e:send(last_presence);
end
end
function e:set_status(t)
local a=a.presence();
if type(t)=="table"then
if t.show then
a:tag("show"):text(t.show):up();
end
if t.prio then
a:tag("priority"):text(tostring(t.prio)):up();
end
if t.msg then
a:tag("status"):text(t.msg):up();
end
end
e:send(a);
end
end
end)
package.preload['verse.plugins.private']=(function(...)
local o=require"verse";
local a="jabber:iq:private";
function o.plugins.private(i)
function i:private_set(i,n,e,s)
local t=o.iq({type="set"})
:tag("query",{xmlns=a});
if e then
if e.name==i and e.attr and e.attr.xmlns==n then
t:add_child(e);
else
t:tag(i,{xmlns=n})
:add_child(e);
end
end
self:send_iq(t,s);
end
function i:private_get(t,i,n)
self:send_iq(o.iq({type="get"})
:tag("query",{xmlns=a})
:tag(t,{xmlns=i}),
function(e)
if e.attr.type=="result"then
local e=e:get_child("query",a);
local e=e:get_child(t,i);
n(e);
end
end);
end
end
end)
package.preload['verse.plugins.roster']=(function(...)
local o=require"verse";
local d=require"util.jid".bare;
local a="jabber:iq:roster";
local n="urn:xmpp:features:rosterver";
local i=table.insert;
function o.plugins.roster(t)
local s=false;
local e={
items={};
ver="";
};
t.roster=e;
t:hook("stream-features",function(e)
if e:get_child("ver",n)then
s=true;
end
end);
local function h(t)
local e=o.stanza("item",{xmlns=a});
for a,t in pairs(t)do
if a~="groups"then
e.attr[a]=t;
else
for a=1,#t do
e:tag("group"):text(t[a]):up();
end
end
end
return e;
end
local function r(t)
local e={};
local a={};
e.groups=a;
local o=t.attr.jid;
for t,a in pairs(t.attr)do
if t~="xmlns"then
e[t]=a
end
end
for e in t:childtags("group")do
i(a,e:get_text())
end
return e;
end
function e:load(t)
e.ver,e.items=t.ver,t.items;
end
function e:dump()
return{
ver=e.ver,
items=e.items,
};
end
function e:add_contact(i,s,n,e)
local i={jid=i,name=s,groups=n};
local a=o.iq({type="set"})
:tag("query",{xmlns=a})
:add_child(h(i));
t:send_iq(a,function(t)
if not e then return end
if t.attr.type=="result"then
e(true);
else
local t,o,a=t:get_error();
e(nil,{t,o,a});
end
end);
end
function e:delete_contact(i,n)
i=(type(i)=="table"and i.jid)or i;
local s={jid=i,subscription="remove"}
if not e.items[i]then return false,"item-not-found";end
t:send_iq(o.iq({type="set"})
:tag("query",{xmlns=a})
:add_child(h(s)),
function(e)
if not n then return end
if e.attr.type=="result"then
n(true);
else
local t,e,a=e:get_error();
n(nil,{t,e,a});
end
end);
end
local function h(t)
local t=r(t);
e.items[t.jid]=t;
end
local function r(t)
local a=e.items[t];
e.items[t]=nil;
return a;
end
function e:fetch(i)
t:send_iq(o.iq({type="get"}):tag("query",{xmlns=a,ver=s and e.ver or nil}),
function(t)
if t.attr.type=="result"then
local t=t:get_child("query",a);
if t then
e.items={};
for t in t:childtags("item")do
h(t)
end
e.ver=t.attr.ver or"";
end
i(e);
else
local t,e,a=stanza:get_error();
i(nil,{t,e,a});
end
end);
end
t:hook("iq/"..a,function(n)
local s,i=n.attr.type,n.attr.from;
if s=="set"and(not i or i==d(t.jid))then
local s=n:get_child("query",a);
local i=s and s:get_child("item");
if i then
local n,a;
local o=i.attr.jid;
if i.attr.subscription=="remove"then
n="removed"
a=r(o);
else
n=e.items[o]and"changed"or"added";
h(i)
a=e.items[o];
end
e.ver=s.attr.ver;
if a then
t:event("roster/item-"..n,a);
end
end
t:send(o.reply(n))
return true;
end
end);
end
end)
package.preload['verse.plugins.register']=(function(...)
local t=require"verse";
local i="jabber:iq:register";
function t.plugins.register(e)
local function a(o)
if o:get_child("register","http://jabber.org/features/iq-register")then
local t=t.iq({to=e.host_,type="set"})
:tag("query",{xmlns=i})
:tag("username"):text(e.username):up()
:tag("password"):text(e.password):up();
if e.register_email then
t:tag("email"):text(e.register_email):up();
end
e:send_iq(t,function(t)
if t.attr.type=="result"then
e:event("registration-success");
else
local a,t,o=t:get_error();
e:debug("Registration failed: %s",t);
e:event("registration-failure",{type=a,condition=t,text=o});
end
end);
else
e:debug("In-band registration not offered by server");
e:event("registration-failure",{condition="service-unavailable"});
end
e:unhook("stream-features",a);
return true;
end
e:hook("stream-features",a,310);
end
end)
package.preload['verse.plugins.groupchat']=(function(...)
local i=require"verse";
local e=require"events";
local n=require"util.jid";
local a={};
a.__index=a;
local h="urn:xmpp:delay";
local s="http://jabber.org/protocol/muc";
function i.plugins.groupchat(o)
o:add_plugin("presence")
o.rooms={};
o:hook("stanza",function(e)
local a=n.bare(e.attr.from);
if not a then return end
local t=o.rooms[a]
if not t and e.attr.to and a then
t=o.rooms[e.attr.to.." "..a]
end
if t and t.opts.source and e.attr.to~=t.opts.source then return end
if t then
local o=select(3,n.split(e.attr.from));
local n=e:get_child_text("body");
local i=e:get_child("delay",h);
local a={
room_jid=a;
room=t;
sender=t.occupants[o];
nick=o;
body=n;
stanza=e;
delay=(i and i.attr.stamp);
};
local t=t:event(e.name,a);
return t or(e.name=="message")or nil;
end
end,500);
function o:join_room(n,h,t)
if not h then
return false,"no nickname supplied"
end
t=t or{};
local e=setmetatable(i.eventable{
stream=o,jid=n,nick=h,
subject=nil,
occupants={},
opts=t,
},a);
if t.source then
self.rooms[t.source.." "..n]=e;
else
self.rooms[n]=e;
end
local a=e.occupants;
e:hook("presence",function(o)
local t=o.nick or h;
if not a[t]and o.stanza.attr.type~="unavailable"then
a[t]={
nick=t;
jid=o.stanza.attr.from;
presence=o.stanza;
};
local o=o.stanza:get_child("x",s.."#user");
if o then
local e=o:get_child("item");
if e and e.attr then
a[t].real_jid=e.attr.jid;
a[t].affiliation=e.attr.affiliation;
a[t].role=e.attr.role;
end
end
if t==e.nick then
e.stream:event("groupchat/joined",e);
else
e:event("occupant-joined",a[t]);
end
elseif a[t]and o.stanza.attr.type=="unavailable"then
if t==e.nick then
e.stream:event("groupchat/left",e);
if e.opts.source then
self.rooms[e.opts.source.." "..n]=nil;
else
self.rooms[n]=nil;
end
else
a[t].presence=o.stanza;
e:event("occupant-left",a[t]);
a[t]=nil;
end
end
end);
e:hook("message",function(a)
local t=a.stanza:get_child_text("subject");
if not t then return end
t=#t>0 and t or nil;
if t~=e.subject then
local o=e.subject;
e.subject=t;
return e:event("subject-changed",{from=o,to=t,by=a.sender,event=a});
end
end,2e3);
local t=i.presence():tag("x",{xmlns=s}):reset();
self:event("pre-groupchat/joining",t);
e:send(t)
self:event("groupchat/joining",e);
return e;
end
o:hook("presence-out",function(e)
if not e.attr.to then
for a,t in pairs(o.rooms)do
t:send(e);
end
e.attr.to=nil;
end
end);
end
function a:send(e)
if e.name=="message"and not e.attr.type then
e.attr.type="groupchat";
end
if e.name=="presence"then
e.attr.to=self.jid.."/"..self.nick;
end
if e.attr.type=="groupchat"or not e.attr.to then
e.attr.to=self.jid;
end
if self.opts.source then
e.attr.from=self.opts.source
end
self.stream:send(e);
end
function a:send_message(e)
self:send(i.message():tag("body"):text(e));
end
function a:set_subject(e)
self:send(i.message():tag("subject"):text(e));
end
function a:leave(e)
self.stream:event("groupchat/leaving",self);
local t=i.presence({type="unavailable"});
if e then
t:tag("status"):text(e);
end
self:send(t);
end
function a:admin_set(e,t,a,o)
self:send(i.iq({type="set"})
:query(s.."#admin")
:tag("item",{nick=e,[t]=a})
:tag("reason"):text(o or""));
end
function a:set_role(a,t,e)
self:admin_set(a,"role",t,e);
end
function a:set_affiliation(a,t,e)
self:admin_set(a,"affiliation",t,e);
end
function a:kick(t,e)
self:set_role(t,"none",e);
end
function a:ban(e,t)
self:set_affiliation(e,"outcast",t);
end
end)
package.preload['verse.plugins.vcard']=(function(...)
local i=require"verse";
local o=require"util.vcard";
local t="vcard-temp";
function i.plugins.vcard(a)
function a:get_vcard(n,e)
a:send_iq(i.iq({to=n,type="get"})
:tag("vCard",{xmlns=t}),e and function(a)
local i,i;
vCard=a:get_child("vCard",t);
if a.attr.type=="result"and vCard then
vCard=o.from_xep54(vCard)
e(vCard)
else
e(false)
end
end or nil);
end
function a:set_vcard(e,n)
local t;
if type(e)=="table"and e.name then
t=e;
elseif type(e)=="string"then
t=o.to_xep54(o.from_text(e)[1]);
elseif type(e)=="table"then
t=o.to_xep54(e);
error("Converting a table to vCard not implemented")
end
if not t then return false end
a:debug("setting vcard to %s",tostring(t));
a:send_iq(i.iq({type="set"})
:add_child(t),n);
end
end
end)
package.preload['verse.plugins.vcard_update']=(function(...)
local n=require"verse";
local e,i="vcard-temp","vcard-temp:x:update";
local e,t=pcall(function()return require("util.hashes").sha1;end);
if not e then
e,t=pcall(function()return require("util.sha1").sha1;end);
if not e then
error("Could not find a sha1()")
end
end
local h=t;
local e,t=pcall(function()
local e=require("util.encodings").base64.decode;
assert(e("SGVsbG8=")=="Hello")
return e;
end);
if not e then
e,t=pcall(function()return require("mime").unb64;end);
if not e then
error("Could not find a base64 decoder")
end
end
local s=t;
function n.plugins.vcard_update(e)
e:add_plugin("vcard");
e:add_plugin("presence");
local t;
function update_vcard_photo(o)
local a;
for e=1,#o do
if o[e].name=="PHOTO"then
a=o[e][1];
break
end
end
if a then
local a=h(s(a),true);
t=n.stanza("x",{xmlns=i})
:tag("photo"):text(a);
e:resend_presence()
else
t=nil;
end
end
local a=e.set_vcard;
local a;
e:hook("ready",function(t)
if a then return;end
a=true;
e:get_vcard(nil,function(t)
if t then
update_vcard_photo(t)
end
e:event("ready");
end);
return true;
end,3);
e:hook("presence-out",function(e)
if t and not e:get_child("x",i)then
e:add_child(t);
end
end,10);
end
end)
package.preload['verse.plugins.carbons']=(function(...)
local a=require"verse";
local o="urn:xmpp:carbons:2";
local n="urn:xmpp:forward:0";
local h=os.time;
local s=require"util.datetime".parse;
local r=require"util.jid".bare;
function a.plugins.carbons(e)
local t={};
t.enabled=false;
e.carbons=t;
function t:enable(i)
e:send_iq(a.iq{type="set"}
:tag("enable",{xmlns=o})
,function(e)
local e=e.attr.type=="result";
if e then
t.enabled=true;
end
if i then
i(e);
end
end or nil);
end
function t:disable(i)
e:send_iq(a.iq{type="set"}
:tag("disable",{xmlns=o})
,function(e)
local e=e.attr.type=="result";
if e then
t.enabled=false;
end
if i then
i(e);
end
end or nil);
end
local i;
e:hook("bind-success",function()
i=r(e.jid);
end);
e:hook("message",function(a)
local t=a:get_child(nil,o);
if a.attr.from==i and t then
local o=t.name;
local t=t:get_child("forwarded",n);
local a=t and t:get_child("message","jabber:client");
local t=t:get_child("delay","urn:xmpp:delay");
local t=t and t.attr.stamp;
t=t and s(t);
if a then
return e:event("carbon",{
dir=o,
stanza=a,
timestamp=t or h(),
});
end
end
end,1);
end
end)
package.preload['verse.plugins.archive']=(function(...)
local o=require"verse";
local t=require"util.stanza";
local a="urn:xmpp:mam:0"
local r="urn:xmpp:forward:0";
local f="urn:xmpp:delay";
local s=require"util.uuid".generate;
local m=require"util.datetime".parse;
local n=require"util.datetime".datetime;
local e=require"util.dataforms".new;
local l=require"util.rsm";
local c={};
local u=e{
{name="FORM_TYPE";type="hidden";value=a;};
{name="with";type="jid-single";};
{name="start";type="text-single"};
{name="end";type="text-single";};
};
function o.plugins.archive(i)
function i:query_archive(o,e,d)
local s=s();
local h=t.iq{type="set",to=o}
:tag("query",{xmlns=a,queryid=s});
local o,t=tonumber(e["start"]),tonumber(e["end"]);
e["start"]=o and n(o);
e["end"]=t and n(t);
h:add_child(u:form(e,"submit"));
h:add_child(l.generate(e));
local o={};
local function i(n)
local e=n:get_child("fin",a)
if e and e.attr.queryid==s then
local e=l.get(e);
for t,e in pairs(e or c)do o[t]=e;end
self:unhook("message",i);
d(o);
return true
end
local e=n:get_child("result",a);
if e and e.attr.queryid==s then
local t=e:get_child("forwarded",r);
t=t or n:get_child("forwarded",r);
local i=e.attr.id;
local e=t:get_child("delay",f);
local a=e and m(e.attr.stamp)or nil;
local e=t:get_child("message","jabber:client")
o[#o+1]={id=i,stamp=a,message=e};
return true
end
end
self:hook("message",i,1);
self:send_iq(h,function(e)
if e.attr.type=="error"then
self:warn(table.concat({e:get_error()}," "))
self:unhook("message",i);
d(false,e:get_error())
end
return true
end);
end
local n={
always=true,[true]="always",
never=false,[false]="never",
roster="roster",
}
local function s(t)
local e={};
local a=t.attr.default;
if a then
e[false]=n[a];
end
local a=t:get_child("always");
if a then
for t in a:childtags("jid")do
local t=t:get_text();
e[t]=true;
end
end
local t=t:get_child("never");
if t then
for t in t:childtags("jid")do
local t=t:get_text();
e[t]=false;
end
end
return e;
end
local function h(o)
local e
e,o[false]=o[false],nil;
if e~=nil then
e=n[e];
end
local i=t.stanza("prefs",{xmlns=a,default=e})
local e=t.stanza("always");
local t=t.stanza("never");
for o,a in pairs(o)do
(a and e or t):tag("jid"):text(o):up();
end
return i:add_child(e):add_child(t);
end
function i:archive_prefs_get(o)
self:send_iq(t.iq{type="get"}:tag("prefs",{xmlns=a}),
function(e)
if e and e.attr.type=="result"and e.tags[1]then
local t=s(e.tags[1]);
o(t,e);
else
o(nil,e);
end
end);
end
function i:archive_prefs_set(e,a)
self:send_iq(t.iq{type="set"}:add_child(h(e)),a);
end
end
end)
package.preload['util.http']=(function(...)
local t,s=string.format,string.char;
local h,o,n=pairs,ipairs,tonumber;
local i,r=table.insert,table.concat;
local function d(e)
return e and(e:gsub("[^a-zA-Z0-9.~_-]",function(e)return t("%%%02x",e:byte());end));
end
local function a(e)
return e and(e:gsub("%%(%x%x)",function(e)return s(n(e,16));end));
end
local function e(e)
return e and(e:gsub("%W",function(e)
if e~=" "then
return t("%%%02x",e:byte());
else
return"+";
end
end));
end
local function s(a)
local t={};
if a[1]then
for o,a in o(a)do
i(t,e(a.name).."="..e(a.value));
end
else
for o,a in h(a)do
i(t,e(o).."="..e(a));
end
end
return r(t,"&");
end
local function n(e)
if not e:match("=")then return a(e);end
local o={};
for e,t in e:gmatch("([^=&]*)=([^&]*)")do
e,t=e:gsub("%+","%%20"),t:gsub("%+","%%20");
e,t=a(e),a(t);
i(o,{name=e,value=t});
o[e]=t;
end
return o;
end
local function t(e,t)
e=","..e:gsub("[ \t]",""):lower()..",";
return e:find(","..t:lower()..",",1,true)~=nil;
end
return{
urlencode=d,urldecode=a;
formencode=s,formdecode=n;
contains_token=t;
};
end)
package.preload['net.http.parser']=(function(...)
local m=tonumber;
local a=assert;
local v=require"socket.url".parse;
local t=require"util.http".urldecode;
local function b(e)
e=t((e:gsub("//+","/")));
if e:sub(1,1)~="/"then
e="/"..e;
end
local t=0;
for e in e:gmatch("([^/]+)/")do
if e==".."then
t=t-1;
elseif e~="."then
t=t+1;
end
if t<0 then
return nil;
end
end
return e;
end
local y={};
function y.new(u,s,e,y)
local d=true;
if not e or e=="server"then d=false;else a(e=="client","Invalid parser type");end
local e="";
local p,o,r;
local h=nil;
local t;
local a;
local c;
local n;
return{
feed=function(l,i)
if n then return nil,"parse has failed";end
if not i then
if h and d and not a then
t.body=e;
u(t);
elseif e~=""then
n=true;return s();
end
return;
end
e=e..i;
while#e>0 do
if h==nil then
local w=e:find("\r\n\r\n",nil,true);
if not w then return;end
local f,r,l,o,g;
local u;
local i={};
for t in e:sub(1,w+1):gmatch("([^\r\n]+)\r\n")do
if u then
local e,t=t:match("^([^%s:]+): *(.*)$");
if not e then n=true;return s("invalid-header-line");end
e=e:lower();
i[e]=i[e]and i[e]..","..t or t;
else
u=t;
if d then
l,o,g=t:match("^HTTP/(1%.[01]) (%d%d%d) (.*)$");
o=m(o);
if not o then n=true;return s("invalid-status-line");end
c=not
((y and y().method=="HEAD")
or(o==204 or o==304 or o==301)
or(o>=100 and o<200));
else
f,r,l=t:match("^(%w+) (%S+) HTTP/(1%.[01])$");
if not f then n=true;return s("invalid-status-line");end
end
end
end
if not u then n=true;return s("invalid-status-line");end
p=c and i["transfer-encoding"]=="chunked";
a=m(i["content-length"]);
if d then
if not c then a=0;end
t={
code=o;
httpversion=l;
headers=i;
body=c and""or nil;
responseversion=l;
responseheaders=i;
};
else
local e;
if r:byte()==47 then
local a,t=r:match("([^?]*).?(.*)");
if t==""then t=nil;end
e={path=a,query=t};
else
e=v(r);
if not(e and e.path)then n=true;return s("invalid-url");end
end
r=b(e.path);
i.host=e.host or i.host;
a=a or 0;
t={
method=f;
url=e;
path=r;
httpversion=l;
headers=i;
body=nil;
};
end
e=e:sub(w+4);
h=true;
end
if h then
if d then
if p then
if not e:find("\r\n",nil,true)then
return;
end
if not o then
o,r=e:match("^(%x+)[^\r\n]*\r\n()");
o=o and m(o,16);
if not o then n=true;return s("invalid-chunk-size");end
end
if o==0 and e:find("\r\n\r\n",r-2,true)then
h,o=nil,nil;
e=e:gsub("^.-\r\n\r\n","");
u(t);
elseif#e-r-2>=o then
t.body=t.body..e:sub(r,r+(o-1));
e=e:sub(r+o+2);
o,r=nil,nil;
else
break;
end
elseif a and#e>=a then
if t.code==101 then
t.body,e=e,"";
else
t.body,e=e:sub(1,a),e:sub(a+1);
end
h=nil;u(t);
else
break;
end
elseif#e>=a then
t.body,e=e:sub(1,a),e:sub(a+1);
h=nil;u(t);
else
break;
end
end
end
end;
};
end
return y;
end)
package.preload['net.http']=(function(...)
local b=require"socket"
local g=require"util.encodings".base64.encode;
local d=require"socket.url"
local u=require"net.http.parser".new;
local h=require"util.http";
local k=pcall(require,"ssl");
local q=require"net.server"
local l,o=table.insert,table.concat;
local m=pairs;
local v,c,f,w,s=
tonumber,tostring,xpcall,select,debug.traceback;
local y,p=assert,error
local r=require"util.logger".init("http");
module"http"
local i={};
local n={default_port=80,default_mode="*a"};
function n.onconnect(t)
local e=i[t];
local a={e.method or"GET"," ",e.path," HTTP/1.1\r\n"};
if e.query then
l(a,4,"?"..e.query);
end
t:write(o(a));
local a={[2]=": ",[4]="\r\n"};
for i,e in m(e.headers)do
a[1],a[3]=i,e;
t:write(o(a));
end
t:write("\r\n");
if e.body then
t:write(e.body);
end
end
function n.onincoming(t,a)
local e=i[t];
if not e then
r("warn","Received response from connection %s with no request attached!",c(t));
return;
end
if a and e.reader then
e:reader(a);
end
end
function n.ondisconnect(t,a)
local e=i[t];
if e and e.conn then
e:reader(nil,a);
end
i[t]=nil;
end
function n.ondetach(e)
i[e]=nil;
end
local function x(e,a,t)
if not e.parser then
local function o(t)
if e.callback then
e.callback(t or"connection-closed",0,e);
e.callback=nil;
end
destroy_request(e);
end
if not a then
o(t);
return;
end
local function a(t)
if e.callback then
e.callback(t.body,t.code,t,e);
e.callback=nil;
end
destroy_request(e);
end
local function t()
return e;
end
e.parser=u(a,o,"client",t);
end
e.parser:feed(a);
end
local function j(e)r("error","Traceback[http]: %s",s(c(e),2));end
function request(e,t,l)
local e=d.parse(e);
if not(e and e.host)then
l(nil,0,e);
return nil,"invalid-url";
end
if not e.path then
e.path="/";
end
local u,o,s;
local h,a=e.host,e.port;
local d=h;
if(a=="80"and e.scheme=="http")
or(a=="443"and e.scheme=="https")then
a=nil;
elseif a then
d=d..":"..a;
end
o={
["Host"]=d;
["User-Agent"]="Prosody XMPP Server";
};
if e.userinfo then
o["Authorization"]="Basic "..g(e.userinfo);
end
if t then
e.onlystatus=t.onlystatus;
s=t.body;
if s then
u="POST";
o["Content-Length"]=c(#s);
o["Content-Type"]="application/x-www-form-urlencoded";
end
if t.method then u=t.method;end
if t.headers then
for t,e in m(t.headers)do
o[t]=e;
end
end
end
e.method,e.headers,e.body=u,o,s;
local o=e.scheme=="https";
if o and not k then
p("SSL not available, unable to contact https URL");
end
local s=a and v(a)or(o and 443 or 80);
local a=b.tcp();
a:settimeout(10);
local u,d=a:connect(h,s);
if not u and d~="timeout"then
l(nil,0,e);
return nil,d;
end
local d=false;
if o then
d=t and t.sslctx or{mode="client",protocol="sslv23",options={"no_sslv2","no_sslv3"}};
end
e.handler,e.conn=y(q.wrapclient(a,h,s,n,"*a",d));
e.write=function(...)return e.handler:write(...);end
e.callback=function(a,t,o,i)r("debug","Calling callback, status %s",t or"---");return w(2,f(function()return l(a,t,o,i)end,j));end
e.reader=x;
e.state="status";
i[e.handler]=e;
return e;
end
function destroy_request(e)
if e.conn then
e.conn=nil;
e.handler:close()
end
end
local o,a=h.urlencode,h.urldecode;
local e,t=h.formencode,h.formdecode;
_M.urlencode,_M.urldecode=o,a;
_M.formencode,_M.formdecode=e,t;
return _M;
end)
package.preload['verse.bosh']=(function(...)
local r=require"util.xmppstream".new;
local s=require"util.stanza";
require"net.httpclient_listener";
local i=require"net.http";
local e=setmetatable({},{__index=verse.stream_mt});
e.__index=e;
local h="http://etherx.jabber.org/streams";
local n="http://jabber.org/protocol/httpbind";
local o=5;
function verse.new_bosh(a,t)
local t={
bosh_conn_pool={};
bosh_waiting_requests={};
bosh_rid=math.random(1,999999);
bosh_outgoing_buffer={};
bosh_url=t;
conn={};
};
function t:reopen()
self.bosh_need_restart=true;
self:flush();
end
local t=verse.new(a,t);
return setmetatable(t,e);
end
function e:connect()
self:_send_session_request();
end
function e:send(e)
self:debug("Putting into BOSH send buffer: %s",tostring(e));
self.bosh_outgoing_buffer[#self.bosh_outgoing_buffer+1]=s.clone(e);
self:flush();
end
function e:flush()
if self.connected
and#self.bosh_waiting_requests<self.bosh_max_requests
and(#self.bosh_waiting_requests==0
or#self.bosh_outgoing_buffer>0
or self.bosh_need_restart)then
self:debug("Flushing...");
local t=self:_make_body();
local e=self.bosh_outgoing_buffer;
for o,a in ipairs(e)do
t:add_child(a);
e[o]=nil;
end
self:_make_request(t);
else
self:debug("Decided not to flush.");
end
end
function e:_make_request(a)
local e,t=i.request(self.bosh_url,{body=tostring(a)},function(i,e,t)
if e~=0 then
self.inactive_since=nil;
return self:_handle_response(i,e,t);
end
local e=os.time();
if not self.inactive_since then
self.inactive_since=e;
elseif e-self.inactive_since>self.bosh_max_inactivity then
return self:_disconnected();
else
self:debug("%d seconds left to reconnect, retrying in %d seconds...",
self.bosh_max_inactivity-(e-self.inactive_since),o);
end
timer.add_task(o,function()
self:debug("Retrying request...");
for e,a in ipairs(self.bosh_waiting_requests)do
if a==t then
table.remove(self.bosh_waiting_requests,e);
break;
end
end
self:_make_request(a);
end);
end);
if e then
table.insert(self.bosh_waiting_requests,e);
else
self:warn("Request failed instantly: %s",t);
end
end
function e:_disconnected()
self.connected=nil;
self:event("disconnected");
end
function e:_send_session_request()
local e=self:_make_body();
e.attr.hold="1";
e.attr.wait="60";
e.attr["xml:lang"]="en";
e.attr.ver="1.6";
e.attr.from=self.jid;
e.attr.to=self.host;
e.attr.secure='true';
i.request(self.bosh_url,{body=tostring(e)},function(e,t)
if t==0 then
return self:_disconnected();
end
local e=self:_parse_response(e)
if not e then
self:warn("Invalid session creation response");
self:_disconnected();
return;
end
self.bosh_sid=e.attr.sid;
self.bosh_wait=tonumber(e.attr.wait);
self.bosh_hold=tonumber(e.attr.hold);
self.bosh_max_inactivity=tonumber(e.attr.inactivity);
self.bosh_max_requests=tonumber(e.attr.requests)or self.bosh_hold;
self.connected=true;
self:event("connected");
self:_handle_response_payload(e);
end);
end
function e:_handle_response(o,t,e)
if self.bosh_waiting_requests[1]~=e then
self:warn("Server replied to request that wasn't the oldest");
for a,t in ipairs(self.bosh_waiting_requests)do
if t==e then
self.bosh_waiting_requests[a]=nil;
break;
end
end
else
table.remove(self.bosh_waiting_requests,1);
end
local e=self:_parse_response(o);
if e then
self:_handle_response_payload(e);
end
self:flush();
end
function e:_handle_response_payload(t)
local e=t.tags;
for t=1,#e do
local e=e[t];
if e.attr.xmlns==h then
self:event("stream-"..e.name,e);
elseif e.attr.xmlns then
self:event("stream/"..e.attr.xmlns,e);
else
self:event("stanza",e);
end
end
if t.attr.type=="terminate"then
self:_disconnected({reason=t.attr.condition});
end
end
local a={
stream_ns="http://jabber.org/protocol/httpbind",stream_tag="body",
default_ns="jabber:client",
streamopened=function(e,t)e.notopen=nil;e.payload=verse.stanza("body",t);return true;end;
handlestanza=function(t,e)t.payload:add_child(e);end;
};
function e:_parse_response(e)
self:debug("Parsing response: %s",e);
if e==nil then
self:debug("%s",debug.traceback());
self:_disconnected();
return;
end
local t={notopen=true,stream=self};
local a=r(t,a);
a:feed(e);
return t.payload;
end
function e:_make_body()
self.bosh_rid=self.bosh_rid+1;
local e=verse.stanza("body",{
xmlns=n;
content="text/xml; charset=utf-8";
sid=self.bosh_sid;
rid=self.bosh_rid;
});
if self.bosh_need_restart then
self.bosh_need_restart=nil;
e.attr.restart='true';
end
return e;
end
end)
package.preload['verse.client']=(function(...)
local t=require"verse";
local o=t.stream_mt;
local r=require"util.jid".split;
local d=require"net.adns";
local e=require"lxp";
local a=require"util.stanza";
t.message,t.presence,t.iq,t.stanza,t.reply,t.error_reply=
a.message,a.presence,a.iq,a.stanza,a.reply,a.error_reply;
local h=require"util.xmppstream".new;
local n="http://etherx.jabber.org/streams";
local function s(e,t)
return e.priority<t.priority or(e.priority==t.priority and e.weight>t.weight);
end
local i={
stream_ns=n,
stream_tag="stream",
default_ns="jabber:client"};
function i.streamopened(e,t)
e.stream_id=t.id;
if not e:event("opened",t)then
e.notopen=nil;
end
return true;
end
function i.streamclosed(e)
e.notopen=true;
if not e.closed then
e:send("</stream:stream>");
e.closed=true;
end
e:event("closed");
return e:close("stream closed")
end
function i.handlestanza(t,e)
if e.attr.xmlns==n then
return t:event("stream-"..e.name,e);
elseif e.attr.xmlns then
return t:event("stream/"..e.attr.xmlns,e);
end
return t:event("stanza",e);
end
function i.error(a,t,e)
if a:event(t,e)==nil then
if e then
local t=e:get_child(nil,"urn:ietf:params:xml:ns:xmpp-streams");
local e=e:get_child_text("text","urn:ietf:params:xml:ns:xmpp-streams");
error(t.name..(e and": "..e or""));
else
error(e and e.name or t or"unknown-error");
end
end
end
function o:reset()
if self.stream then
self.stream:reset();
else
self.stream=h(self,i);
end
self.notopen=true;
return true;
end
function o:connect_client(e,a)
self.jid,self.password=e,a;
self.username,self.host,self.resource=r(e);
self:add_plugin("tls");
self:add_plugin("sasl");
self:add_plugin("bind");
self:add_plugin("session");
function self.data(t,e)
local a,t=self.stream:feed(e);
if a then return;end
self:debug("debug","Received invalid XML (%s) %d bytes: %s",tostring(t),#e,e:sub(1,300):gsub("[\r\n]+"," "));
self:close("xml-not-well-formed");
end
self:hook("connected",function()self:reopen();end);
self:hook("incoming-raw",function(e)return self.data(self.conn,e);end);
self.curr_id=0;
self.tracked_iqs={};
self:hook("stanza",function(t)
local e,a=t.attr.id,t.attr.type;
if e and t.name=="iq"and(a=="result"or a=="error")and self.tracked_iqs[e]then
self.tracked_iqs[e](t);
self.tracked_iqs[e]=nil;
return true;
end
end);
self:hook("stanza",function(e)
local a;
if e.attr.xmlns==nil or e.attr.xmlns=="jabber:client"then
if e.name=="iq"and(e.attr.type=="get"or e.attr.type=="set")then
local o=e.tags[1]and e.tags[1].attr.xmlns;
if o then
a=self:event("iq/"..o,e);
if not a then
a=self:event("iq",e);
end
end
if a==nil then
self:send(t.error_reply(e,"cancel","service-unavailable"));
return true;
end
else
a=self:event(e.name,e);
end
end
return a;
end,-1);
self:hook("outgoing",function(e)
if e.name then
self:event("stanza-out",e);
end
end);
self:hook("stanza-out",function(e)
if not e.attr.xmlns then
self:event(e.name.."-out",e);
end
end);
local function e()
self:event("ready");
end
self:hook("session-success",e,-1)
self:hook("bind-success",e,-1);
local e=self.close;
function self:close(t)
self.close=e;
if not self.closed then
self:send("</stream:stream>");
self.closed=true;
else
return self:close(t);
end
end
local function a()
self:connect(self.connect_host or self.host,self.connect_port or 5222);
end
if not(self.connect_host or self.connect_port)then
d.lookup(function(t)
if t then
local e={};
self.srv_hosts=e;
for a,t in ipairs(t)do
table.insert(e,t.srv);
end
table.sort(e,s);
local t=e[1];
self.srv_choice=1;
if t then
self.connect_host,self.connect_port=t.target,t.port;
self:debug("Best record found, will connect to %s:%d",self.connect_host or self.host,self.connect_port or 5222);
end
self:hook("disconnected",function()
if self.srv_hosts and self.srv_choice<#self.srv_hosts then
self.srv_choice=self.srv_choice+1;
local e=e[self.srv_choice];
self.connect_host,self.connect_port=e.target,e.port;
a();
return true;
end
end,1e3);
self:hook("connected",function()
self.srv_hosts=nil;
end,1e3);
end
a();
end,"_xmpp-client._tcp."..(self.host)..".","SRV");
else
a();
end
end
function o:reopen()
self:reset();
self:send(a.stanza("stream:stream",{to=self.host,["xmlns:stream"]='http://etherx.jabber.org/streams',
xmlns="jabber:client",version="1.0"}):top_tag());
end
function o:send_iq(t,a)
local e=self:new_id();
self.tracked_iqs[e]=a;
t.attr.id=e;
self:send(t);
end
function o:new_id()
self.curr_id=self.curr_id+1;
return tostring(self.curr_id);
end
end)
package.preload['verse.component']=(function(...)
local a=require"verse";
local o=a.stream_mt;
local d=require"util.jid".split;
local e=require"lxp";
local t=require"util.stanza";
local r=require"util.sha1".sha1;
a.message,a.presence,a.iq,a.stanza,a.reply,a.error_reply=
t.message,t.presence,t.iq,t.stanza,t.reply,t.error_reply;
local h=require"util.xmppstream".new;
local s="http://etherx.jabber.org/streams";
local i="jabber:component:accept";
local n={
stream_ns=s,
stream_tag="stream",
default_ns=i};
function n.streamopened(e,t)
e.stream_id=t.id;
if not e:event("opened",t)then
e.notopen=nil;
end
return true;
end
function n.streamclosed(e)
return e:event("closed");
end
function n.handlestanza(t,e)
if e.attr.xmlns==s then
return t:event("stream-"..e.name,e);
elseif e.attr.xmlns or e.name=="handshake"then
return t:event("stream/"..(e.attr.xmlns or i),e);
end
return t:event("stanza",e);
end
function o:reset()
if self.stream then
self.stream:reset();
else
self.stream=h(self,n);
end
self.notopen=true;
return true;
end
function o:connect_component(e,n)
self.jid,self.password=e,n;
self.username,self.host,self.resource=d(e);
function self.data(t,e)
local t,a=self.stream:feed(e);
if t then return;end
o:debug("debug","Received invalid XML (%s) %d bytes: %s",tostring(a),#e,e:sub(1,300):gsub("[\r\n]+"," "));
o:close("xml-not-well-formed");
end
self:hook("incoming-raw",function(e)return self.data(self.conn,e);end);
self.curr_id=0;
self.tracked_iqs={};
self:hook("stanza",function(t)
local e,a=t.attr.id,t.attr.type;
if e and t.name=="iq"and(a=="result"or a=="error")and self.tracked_iqs[e]then
self.tracked_iqs[e](t);
self.tracked_iqs[e]=nil;
return true;
end
end);
self:hook("stanza",function(e)
local t;
if e.attr.xmlns==nil or e.attr.xmlns=="jabber:client"then
if e.name=="iq"and(e.attr.type=="get"or e.attr.type=="set")then
local o=e.tags[1]and e.tags[1].attr.xmlns;
if o then
t=self:event("iq/"..o,e);
if not t then
t=self:event("iq",e);
end
end
if t==nil then
self:send(a.error_reply(e,"cancel","service-unavailable"));
return true;
end
else
t=self:event(e.name,e);
end
end
return t;
end,-1);
self:hook("opened",function(e)
print(self.jid,self.stream_id,e.id);
local e=r(self.stream_id..n,true);
self:send(t.stanza("handshake",{xmlns=i}):text(e));
self:hook("stream/"..i,function(e)
if e.name=="handshake"then
self:event("authentication-success");
end
end);
end);
local function e()
self:event("ready");
end
self:hook("authentication-success",e,-1);
self:connect(self.connect_host or self.host,self.connect_port or 5347);
self:reopen();
end
function o:reopen()
self:reset();
self:send(t.stanza("stream:stream",{to=self.jid,["xmlns:stream"]='http://etherx.jabber.org/streams',
xmlns=i,version="1.0"}):top_tag());
end
function o:close(t)
if not self.notopen then
self:send("</stream:stream>");
end
local e=self.conn.disconnect();
self.conn:close();
e(conn,t);
end
function o:send_iq(e,a)
local t=self:new_id();
self.tracked_iqs[t]=a;
e.attr.id=t;
self:send(e);
end
function o:new_id()
self.curr_id=self.curr_id+1;
return tostring(self.curr_id);
end
end)
pcall(require,"luarocks.require");
local s=require"socket";
pcall(require,"ssl");
local a=require"net.server";
local n=require"util.events";
local o=require"util.logger";
module("verse",package.seeall);
local e=_M;
_M.server=a;
local t={};
t.__index=t;
stream_mt=t;
e.plugins={};
function e.init(...)
for e=1,select("#",...)do
local t=pcall(require,"verse."..select(e,...));
if not t then
error("Verse connection module not found: verse."..select(e,...));
end
end
return e;
end
local i=0;
function e.new(a,o)
local t=setmetatable(o or{},t);
i=i+1;
t.id=tostring(i);
t.logger=a or e.new_logger("stream"..t.id);
t.events=n.new();
t.plugins={};
t.verse=e;
return t;
end
e.add_task=require"util.timer".add_task;
e.logger=o.init;
e.new_logger=o.init;
e.log=e.logger("verse");
local function i(o,...)
local e,a,t=0,{...},select('#',...);
return(o:gsub("%%(.)",function(o)if e<=t then e=e+1;return tostring(a[e]);end end));
end
function e.set_log_handler(e,t)
t=t or{"debug","info","warn","error"};
o.reset();
if io.type(e)=="file"then
local a=e;
function e(o,t,e)
a:write(o,"\t",t,"\t",e,"\n");
end
end
if e then
local function a(t,o,a,...)
return e(t,o,i(a,...));
end
for t,e in ipairs(t)do
o.add_level_sink(e,a);
end
end
end
function _default_log_handler(t,o,a)
return io.stderr:write(t,"\t",o,"\t",a,"\n");
end
e.set_log_handler(_default_log_handler,{"error"});
local function o(t)
e.log("error","Error: %s",t);
e.log("error","Traceback: %s",debug.traceback());
end
function e.set_error_handler(e)
o=e;
end
function e.loop()
return xpcall(a.loop,o);
end
function e.step()
return xpcall(a.step,o);
end
function e.quit()
return a.setquitting(true);
end
function t:listen(e,t)
e=e or"localhost";
t=t or 0;
local a,o=a.addserver(e,t,new_listener(self,"server"),"*a");
if a then
self:debug("Bound to %s:%s",e,t);
self.server=a;
end
return a,o;
end
function t:connect(t,o)
t=t or"localhost";
o=tonumber(o)or 5222;
local i=s.tcp()
i:settimeout(0);
local n,e=i:connect(t,o);
if not n and e~="timeout"then
self:warn("connect() to %s:%d failed: %s",t,o,e);
return self:event("disconnected",{reason=e})or false,e;
end
local t=a.wrapclient(i,t,o,new_listener(self),"*a");
if not t then
self:warn("connection initialisation failed: %s",e);
return self:event("disconnected",{reason=e})or false,e;
end
self:set_conn(t);
return true;
end
function t:set_conn(t)
self.conn=t;
self.send=function(a,e)
self:event("outgoing",e);
e=tostring(e);
self:event("outgoing-raw",e);
return t:write(e);
end;
end
function t:close(t)
if not self.conn then
e.log("error","Attempt to close disconnected connection - possibly a bug");
return;
end
local e=self.conn.disconnect();
self.conn:close();
e(self.conn,t);
end
function t:debug(...)
return self.logger("debug",...);
end
function t:info(...)
return self.logger("info",...);
end
function t:warn(...)
return self.logger("warn",...);
end
function t:error(...)
return self.logger("error",...);
end
function t:event(e,...)
self:debug("Firing event: "..tostring(e));
return self.events.fire_event(e,...);
end
function t:hook(e,...)
return self.events.add_handler(e,...);
end
function t:unhook(e,t)
return self.events.remove_handler(e,t);
end
function e.eventable(e)
e.events=n.new();
e.hook,e.unhook=t.hook,t.unhook;
local t=e.events.fire_event;
function e:event(e,...)
return t(e,...);
end
return e;
end
function t:add_plugin(t)
if self.plugins[t]then return true;end
if require("verse.plugins."..t)then
local e,a=e.plugins[t](self);
if e~=false then
self:debug("Loaded %s plugin",t);
self.plugins[t]=true;
else
self:warn("Failed to load %s plugin: %s",t,a);
end
end
return self;
end
function new_listener(t)
local a={};
function a.onconnect(a)
if t.server then
local e=e.new();
a:setlistener(new_listener(e));
e:set_conn(a);
t:event("connected",{client=e});
else
t.connected=true;
t:event("connected");
end
end
function a.onincoming(a,e)
t:event("incoming-raw",e);
end
function a.ondisconnect(a,e)
if a~=t.conn then return end
t.connected=false;
t:event("disconnected",{reason=e});
end
function a.ondrain(e)
t:event("drained");
end
function a.onstatus(a,e)
t:event("status",e);
end
return a;
end
return e;