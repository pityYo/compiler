%{
#define LIST               strcat(buf, yytext)
#define token(t)           {LIST; if (Opt_T) printf("<%s>\n", #t);}
#define tokenChar(t)       {LIST; if (Opt_T) printf("<%c>\n", (t));}
#define tokenInteger(t, i) {LIST; if (Opt_T) printf("<%s: %d>\n", #t, (i));}
#define tokenString(t, s)  {LIST; if (Opt_T) printf("<%s: %s>\n", #t, (s));}
#define MAX_LINE_LENG      256

int Opt_S = 1;
int Opt_T = 1;
int linenum = 1;
char buf[MAX_LINE_LENG];
%}

comma             			[,]
semicolon         			[;]
colon             			[:]
left_parentheses       		[(]
right_parentheses           [)]
left_square_bracket   		\[
right_square_bracket        \]
addition          			\+
substraction       			\-
multiplication    			\*
division          			\/
MOD               			"mod"
assignment        			":="
lt                			[<]
le                			"<="
lg                			"<>"
ge                			">="
gt                			[>]
eq                			[=]
and               			"and"
or                			"or"
not               			"not"
Keywords          			"array"|"begin"|"boolean"|"def"|"do"|"else"|"end"|"false"|"for"|"integer"|"if"|"of"|"print"|"read"|"real"|"string"|"then"|"to"|"true"|"return"|"var"|"while"
							
Identifier        			[a-zA-Z][0-9a-zA-Z]*
Integer           			0|([1-9][0-9]*)
Oct_integer					[0][0-7]+
Floating_point    			[0-9]+\.[0-9]+
Scientific_Notation			(([0-9]+)|([0-9]+\.[0-9]+))[Ee][+-]?[0-9]+
String                      \"([\40-\41]|(\"\")|[\43-\176])*\"
whitespace                  [ \t]
opt_s_on                    "\/\/&S+".*
opt_s_off					"\/\/&S-".*
opt_t_on					"\/\/&T+".*
opt_t_off                   "\/\/&T-".*
comment                     \/\/.*
         



%x COMMENT

%%
"/*"                {LIST; BEGIN COMMENT;}
<COMMENT>.			LIST;
<COMMENT>\n        	{
						LIST;
						if(Opt_S)
							printf("%d: %s", linenum, buf);
						linenum++;
						buf[0] = '\0';
					}
<COMMENT>"*/"		{LIST; BEGIN INITIAL;}			

"\n"      {
			LIST;
			if(Opt_S)
				printf("%d: %s", linenum, buf);
			linenum++;
			buf[0] = '\0';
			
		} 
{Keywords}      {
					LIST;
					if(Opt_T)
						printf("<KW%s>\n", yytext);
					
				}
{comma}         {tokenChar(',');}
{semicolon}     {tokenChar(';');}
{colon}         {tokenChar(':');}
{left_parentheses}        		{tokenChar('(');}
{right_parentheses}             {tokenChar(')');}
{left_square_bracket}   		{tokenChar('[');}
{right_square_bracket}          {tokenChar(']');}
{addition}                      {tokenChar('+');}
{substraction}                  {tokenChar('-');}
{multiplication}                {tokenChar('*');}
{division}                      {tokenChar('/');}
{MOD}                           {token(mod);}
{assignment}                    {token(:=);}
{lt}                			{tokenChar('<');}
{le}               			    {token(<=);}
{lg}                			{token(<>);}
{ge}                			{token(>=);}
{gt}                			{tokenChar('>');}
{eq}                			{tokenChar('=');}
{and}               			{token(and);}
{or}                			{token(or);}
{not}                           {token(not);}
{Identifier}                    {tokenString(id, yytext);}
{whitespace}                    {LIST;}
{Integer}                       {tokenString(integer, yytext);}
{Oct_integer}                   {tokenString(oct_integer, yytext);}
{Floating_point}                {tokenString(float,yytext);}
{Scientific_Notation}           {tokenString(scientific, yytext);}
{String}                        {
									LIST;
									if(Opt_T){
										char str[MAX_LINE_LENG];
										str[0] = '\0';
										char ans[MAX_LINE_LENG];
										strcat(str, yytext);
										int len = strlen(str), i, cnt = 0;
										for(i = 1; i < len-1 ; ++i){
											if(str[i] == '\"')
												++i;
											ans[cnt++] = str[i];
										}
										ans[cnt] = '\0';
										printf("<string: %s>\n", ans);
									}
								}
{opt_s_off}						{LIST; Opt_S = 0;}
{opt_s_on}						{LIST; Opt_S = 1;}
{opt_t_off}                     {LIST; Opt_T = 0;}
{opt_t_on}                      {LIST; Opt_T = 1;}
{comment}     					{LIST;}
[\40-\176]        {printf("error at line %d: bad character \"%s\"\n",linenum,yytext); exit(0);}






%%
int main( int argc, char **argv )
{
  if( argc != 2 ) {
    fprintf( stderr, "Usage: ./scanner [filename]\n" );
    exit(0);
  }
	
  FILE *fp = fopen( argv[1], "r" );
  if( fp == NULL ) {
    fprintf( stderr, "Open file error\n" );
    exit(-1);
  }
	
  yyin = fp;

  yylex();

  exit(0);
}
