select 
regexp_substr('ENT*684*2J*EI*00002300010061817NYJ~', '[^*|~]+',1,1), 
regexp_substr('ENT*684*2J*EI*00002300010061817NYJ~', '[^*|~]+',1,2),
regexp_substr('ENT*684*2J*EI*00002300010061817NYJ~', '[^*|~]+',1,3),
regexp_substr('ENT*684*2J*EI*00002300010061817NYJ~', '[^*|~]+',1,4),
regexp_substr('ENT*684*2J*EI*00002300010061817NYJ~', '[^*|~]+',1,5)
from dual;
