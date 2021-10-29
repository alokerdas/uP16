/************************************************************************************************
//////////////////////////////// ASSEMBLER OF 16-BIT MICROPROCER ////////////////////////////////
*************************************************************************************************
_______________________________________________________________________________________________*/
//   Take Input File - any file name
//  Give Output File "prog.mem" which accessable to 16-bit Microprocessor


#include<iostream>
#include<fstream>
#include<string.h>
#include<stdlib.h>
#include<map>

#define SIZE    320
#define ERROR   fp.close();system("rm prog.mem");exit(0);
#define SETUPI \
	    { string str3 = i0+str1;\
              char* str4=(char*)str3.c_str(); \
	      m = strtol(str4,&endptr,2);\
	      outf<<hex<<m;}

using namespace std;

typedef map<string,int>table1;
typedef map<string,string>table;
int main(int argc, char **argv)
{
  table1 addr_smbl_tbl;
  long lc = 0, val = 0, val1 = 0, m = 0, n;
  int error = 0, end = 0, org = 0, skip = 0, skip1 = 0;
  char buffer[SIZE];
  char *line, *label, *token, *token1, *token2, *token4, *x, *i, *a, *b, *c, *d, *e, *endptr, *line0,*line1, *line2, *line3, *myline; 
static const char *line6, *line7, *line8, *line9;

  fflush(stdin);
  const char* inFile = argv[1]? strdup(argv[1]) : NULL;
  //aloke ifstream fp("prog_assembler.txt", std::ifstream::in);
  ifstream fp(inFile);
  ofstream outf("prog.mem");
  if(!fp)
  {
    puts("ERROR TO OPENING THE FILE.");
    ERROR
  }

  while(fp)
  {
    fp.getline(buffer,SIZE);
    if(strstr(buffer,"END"))
    {
      end = 1;
      break;
    }
    else
    end = 0;
  }
  fp.seekg(0, ios::beg);

  if(end)	
  {
    while(fp)
    {
      fp.getline(buffer,SIZE);
      error++;
      if(strcmp(buffer,""))
      {
	if(buffer[0] == ' ' || buffer[0] == '	')
	{
	  cout<<"Line No:"<<error<<". ERROR ! An unwanted blank space or a blank tab.\n";
	  ERROR
	}
        else if(buffer[0] == '/' && buffer[1] == '/')line = NULL;
        else if(strstr(buffer,"//"))myline = strtok(buffer,"//");
        else myline = strtok(buffer,"\n");
        if(myline)
	{
	    if(!skip && (strstr(myline,"/*")))
	    {
		if((myline[0] == '/') && (myline[1] == '*'))
	        {
		    line1 = NULL;
		    skip = 1;
		}
		else if(strstr(myline,"*/"))
		{
		    line1 = strtok(myline,"/*");
		    line3 = strtok(NULL,"\n");
		    line0 = strtok(line3,"/");
		    line2 = strtok(NULL,"\n");
		    if(line2)
                	strcat(line1,line2);
		    else 
			strcat(line1,"");
                        strcpy(myline,line1);
		}
		else
		{
	 	    line8 = strtok(myline,"/");
                    line9 = strdup(line8);  
                    skip1 = 1;
		    skip = 1;
		}
	    }
	    else if (skip && !(strstr(myline,"/*")) && (strstr(myline,"*/")))
	    {
		line0 = strtok(myline,"/");
		line2=strtok(NULL,"\n");
                if(skip1)
		{   
                    line0 = strdup(line9);
		    if(line2)
			strcat(line0,line2);
		    else
			strcat(line0,"");
                    strcpy(myline,line0);
		    skip1=0;
		}
		else myline = line2;
		skip = 0;
	    }
	    else if(!skip && strstr(buffer,"/"))
	    {
	        cout<<"Line No:"<<error<<". ERROR ! Give '//' before COMMENT part.\n";
		ERROR
	    }
	    line = myline;
	}

	if(line && !skip)
	{
	  label = NULL;
	  if(strstr(line,","))
          {
	    token1 = line;
//	    TOKENIZE1
	    if(strstr(token1,", "))
	    {
		label = strtok(token1,", ");
		//TOKENIZE
		c = strtok(NULL,"\n");
		token1 = strtok(c," ");
		d = strtok(NULL,"\n");
		token2 = strtok(d," ");
		e = strtok(NULL,"\n");
		i = strtok(e," ");
	    }
	    else if(strstr(token1,","))
	    {
		label = strtok(token1,",");
		//TOKENIZE
		c = strtok(NULL,"\n");
		token1 = strtok(c," ");
		d = strtok(NULL,"\n");
		token2 = strtok(d," ");
		e = strtok(NULL,"\n");
		i = strtok(e," ");
	    }
	    
	  }
	  else
	  {
            token1 = strtok(line," ");
            token2 = strtok(NULL," ");
	  }
	    

////////////////////////////////////////////////////////////////////////////////////////////////////////////////* FIRST PASS *//////////////////////////////////


          if(label)
	  {
	    table1::iterator itraddr;
	    itraddr = addr_smbl_tbl.find(label);
	    if(itraddr != addr_smbl_tbl.end())
	    {
		cout<<"Line No:"<<error<<". ERROR ! Address Symbol '"<<label<<"' is over writting. Give another Address Symbol.\n";
                ERROR
            }
            else
	    {
              addr_smbl_tbl[label] = lc;      // STORING VALUE IN 
              lc++;                           // ADDRESS SYMBOL TABLE
            }
	  } 
          else
          {
            if(!strcmp(token1,"ORG"))
            {
              if(token2)
              {
                val = strtol(token2, &endptr, 16);
                lc = val;
              }
              else
              {
                cout<<"Line No:"<<error<<". ERROR ! After ""ORG"" ADDR"" part missing.\n";
                ERROR
              }
            }
            else if(!strcmp(token1,"END"))
            {
              fp.close();
              goto SECOND_PASS;
            }
            else
              lc++;
	  }
        } // End If line
      }  // End if buffer
    }  // End file (while loop)
    fp.close();
    
    
////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////* SECOND PASS *////////////////////////////////

    SECOND_PASS:

//////////////////////////////////* TABLES *////////////////////////////////////

    error = 0, lc = 0, val = 0;
    table pseudo, MRI, non_MRI;   
    pseudo["ORG"];
    pseudo["HEX"];
    pseudo["DEC"];
    pseudo["END"];

    MRI["AND"] = "000";
    MRI["ADD"] = "001";
    MRI["LDA"] = "010";
    MRI["STA"] = "011";
    MRI["BUN"] = "100";
    MRI["BSA"] = "101";
    MRI["ISZ"] = "110";

    non_MRI["CLA"] = "7800";
    non_MRI["CLE"] = "7400";
    non_MRI["CMA"] = "7200";
    non_MRI["CME"] = "7100";
    non_MRI["CIR"] = "7080";
    non_MRI["CIL"] = "7040";
    non_MRI["INC"] = "7020";
    non_MRI["SPA"] = "7010";
    non_MRI["SNA"] = "7008";
    non_MRI["SZA"] = "7004";
    non_MRI["SZE"] = "7002";
    non_MRI["HLT"] = "7001";
    non_MRI["INP"] = "f800";
    non_MRI["OUT"] = "f400";
    non_MRI["SKI"] = "f200";
    non_MRI["SKO"] = "f100";
    non_MRI["ION"] = "f080";
    non_MRI["IOF"] = "f040";
    
////////////////////////////////////////////////////////////////////////////////
     
    ifstream fp(inFile);
    if(!fp)
      puts("ERROR TO OPENING THE FILE.");

    while(fp)
    {
      fp.getline(buffer,SIZE);
      error++;
      if(strcmp(buffer,""))
      {
        if(buffer[0] == '/' && buffer[1] == '/'){line = NULL;myline = NULL;}
        else if(strstr(buffer,"//"))myline = strtok(buffer,"//");
        else myline = strtok(buffer,"\n");
        if(myline)
	{
	    if(!skip && (strstr(myline,"/*")))
	    {
		if((myline[0] == '/') && (myline[1] == '*'))
	        {
		    line1 = NULL;
		    skip = 1;
		}
		else if(strstr(myline,"*/"))
		{
		    line1 = strtok(myline,"/*");
		    line3 = strtok(NULL,"\n");
		    line0 = strtok(line3,"/");
		    line2 = strtok(NULL,"\n");
		    if(line2)
                	strcat(line1,line2);
		    else 
			strcat(line1,"");
                        strcpy(myline,line1);
		}
		else
		{
	 	    line8 = strtok(myline,"/");
                    line9 = strdup(line8);  
                    skip1 = 1;
		    skip = 1;
		}
	    }
	    else if (skip && !(strstr(myline,"/*")) && (strstr(myline,"*/")))
	    {
		line0 = strtok(myline,"/");
		line2=strtok(NULL,"\n");
                if(skip1)
		{   
		    line0 = strdup(line9);
		    if(line2)
			strcat(line0,line2);
		    else
			strcat(line0,"");
                    strcpy(myline,line0);
		    skip1=0;
		}
		else myline = line2;
		skip = 0;
	    }
	    else if(!skip && strstr(buffer,"/"))
	    {
	        cout<<"Line No:"<<error<<". ERROR ! Give '//' before COMMENT part.\n";
		ERROR
	    }
	    line = myline;
	}



        if(line && !skip)
        {
          label = NULL;
          if(strstr(line,","))
          {
	    token1 = line;
	    //TOKENIZE1
	    if(strstr(token1,", "))
	    {
		label = strtok(token1,", ");
	//	TOKENIZE
		c = strtok(NULL,"\n");
		token1 = strtok(c," ");
		d = strtok(NULL,"\n");
		token2 = strtok(d," ");
		e = strtok(NULL,"\n");
		i = strtok(e," ");
	    }
	    else if(strstr(token1,","))
	    {
		label = strtok(token1,",");
	//	TOKENIZE
		c = strtok(NULL,"\n");
		token1 = strtok(c," ");
		d = strtok(NULL,"\n");
		token2 = strtok(d," ");
		e = strtok(NULL,"\n");
		i = strtok(e," ");
	    }
	  } 
          else
	  {
	    token1 = strtok(line," ");
	    a = strtok(NULL,"\n");
    	    token2 = strtok(a," ");
	    b = strtok(NULL,"\n");
	    i = strtok(b," ");
	  }
	    
          if(i && strcmp(i,"I"))              
          {
            cout<<"Line No:"<<error<<". ERROR !Addressing part is not correct.\n";
            ERROR
          }
          if(!strcmp(token1,"END") &&  org == 0)
          {
            cout<<"Line No:"<<error<<". ERROR ! Program is not yet complete (At least 1 line expected).\n";
            ERROR
          }
          table::iterator itrv;
  	  table::iterator itrmri;
          table::iterator itrnmri;
    	  itrv = pseudo.find(token1);
	  itrmri = MRI.find(token1);
	  itrnmri = non_MRI.find(token1);

////////////////////////////////////////////////////////////////////////////////////////////////////////* FOR PSEUDO INSTRUCTION *//////////////////////////////


	  if(itrv != pseudo.end())
	  {
    	      if(!strcmp(token1,"ORG") && strcmp(token2,""))
	      {
	        if(!strcmp(token2,"000") || !strcmp(token2,"00") || !strcmp(token2,"0"))
	        { 
	          lc = 0;
	        } 
	        else
	        { 
	          val = strtol(token2,&endptr,16);
	          lc = val;
	          if(!val)
	          {
    	            cout<<"Line No:"<<error<<". ERROR ! Address part is not a hexadecimal number or Put upto three 'ZERO'.\n";
		    ERROR
		  }
	        }
	        if(lc > 4095 || lc < 0)
	        {
	          cout<<"Line No:"<<error<<". ERROR !Address out of range.\n";
	          ERROR
                } 
	        else
	        {
	          outf<<"@";
	          if(lc < 16)outf<<"00";
	          if(lc > 15 && lc < 256)outf<<"0";
	          outf<<hex<<lc<<endl;
	        }
   	      }
    	      else if(!strcmp(token1,"DEC") && token2)
              {
		long dec;
	        org += 1;
  		if(!strcmp(token2,"0000") || !strcmp(token2,"000") || !strcmp(token2,"00") || !strcmp(token2,"0"))
    		  outf<<"0000"<<endl;
  		else
  		{ 
    		  dec = strtol(token2,&endptr,10);
    		  if(!dec)
    		  {
      		    cout<<"Line No:"<<error<<". ERROR ! Data part is not an integer number or put upto four 'ZERO'.\n";
      		    ERROR
    		  }
  		}
  		if(dec > 65535 || dec < -65536)
  		{
    		  cout<<"Line No:"<<error<<". ERROR !Data out of range.\n";
    		  ERROR
  		}
  		else
  		{
    		  if(dec>0 && dec<16)outf<<"000";
    		  if(dec>15 && dec < 256)outf<<"00";
    		  if(dec>255 && dec < 4096)outf<<0;
    		  outf<<hex<<dec<<endl;
    		  lc++;
  		}
	      }
    	      else if(token2 && !strcmp(token1,"HEX"))
	      {
	        long dec1;
	        org += 1;
	        if(!strcmp(token2,"0000") || !strcmp(token2,"000") || !strcmp(token2,"00") || !strcmp(token2,"0"))
	          dec1 = 0;
	        else
	        { 
	          dec1 = strtol(token2,&endptr,16);
	          if(!dec1)
		  {
    	            cout<<"Line No:"<<error<<". ERROR ! Data part is not a hexadecimal number or Put upto four 'ZERO'. \n";
		    ERROR
		  }
	        }
	        if(dec1 > 65535 || dec1 < -65536)
	        {
    	          cout<<"ERROR !Data out of range.Line no "<<error<<".\n";
	          ERROR
	        }
	        else if(dec1> -1)
	        {
		  if(dec1<16)outf<<"000";
		  if(dec1>15 && dec1 < 256)outf<<"00";
		  if(dec1>255 && dec1 < 4096)outf<<0;
		}
		outf<<hex<<dec1<<endl;
		lc++;
	      }
    	      else if(!strcmp(token1,"END"))
	      {
	        if(lc > 4095)
	        {
	          cout<<"ERROR ! Address out of range.\n";
	          ERROR
	        }
	        else
	        {
    	          cout<<"Now run the MICROPROCESSOR program.Best of luck......!\n";
	          fp.close();
	          exit(0);
	        }
	      }
	      else
	      { 
    	        cout<<"Line No:"<<error<<". ERROR ! Data part missing.\n";
	        ERROR
	      }
	  }
		
/////////////////////////////////////////////////////////////////////////////////////////////////////////* FOR MEMORY INSTRUCTION */////////////////////////////

		
	  else if(itrmri != MRI.end())
	  {
	    org += 1;
	    if(!token2)
	    {
	      cout<<"Line No:"<<error<<". ERROR ! Address symbol part missing.\n";
              ERROR
	    }
	    table1::iterator itraddr;
	    itraddr = addr_smbl_tbl.find(token2);
	    if(itraddr != addr_smbl_tbl.end())
	      n = addr_smbl_tbl[token2];
	    else
            {
	      cout<<"Line No:"<<error<<". ERROR ! Address symbol not matching.\n";
	      ERROR
	    }
	    string str1 = (*itrmri).second;
	    if(i && !strcmp(i,"I"))
	    {
	      char i0 = '1';
	      SETUPI
	    }
	    else
	    {
	      char i0 = '0';   
	      SETUPI
	    }
            if(n < 16)outf<<"00";
    	    if(n > 15 && n < 256)outf<<00;
	    outf<<hex<<n<<endl;
	    lc++;
	  }  

		
///////////////////////////////////////////////////////////////////////////////////////////////////////* FOR NON MEMORY INSTRUCTION *///////////////////////////

		
	  else if(itrnmri != non_MRI.end())
	  {
	    org += 1;
	    outf<<(*itrnmri).second<<endl;
	    lc++;
    	  }

////////////////////////////////////////////////////////////////////////////////

	  else
	  {
    	    cout<<"Line No:"<<error<<". ERROR ! Invalid instruction or Use 'SPACE' instead 'TAB'.\n";
	    ERROR
	  }
        } //End if line
      } // End if buffer
    } // end while
  }
  if(end == 0)	
  {
    cout<<"ERROR ! Ending line 'END' missing.\n";
    ERROR
  }
}
