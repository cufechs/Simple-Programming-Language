using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace Compilers_GUI
{
	class CodeGenerator
	{
        enum OperationType
        {
            Q_Assign = 20,
            Q_ADD,
            Q_SUB,
            Q_MUL,
            Q_DIV,
            Q_LOGIC_AND,
            Q_LOGIC_OR,
            Q_EQ,
            Q_NE,
            Q_GE,
            Q_LE,
            Q_GT,
            Q_LT,
            Q_JZ,
            Q_JNZ,
            Q_JMP,
            Q_LABEL,
            Q_INC,
            Q_DEC,
            Q_PUSH,
            Q_POP
        }

        struct Quadruple
        {
            public string Result;
            public string Src1;
            public string Src2;
            public OperationType Operation;
            //public int BasicGroupNum;
        }

        public static bool GenerateCode()
        {
            string FilePath = "quad.txt";
            List<List<Quadruple>> BasicGroups = new List<List<Quadruple>>();

            try
            {

                using (StreamReader SR = new StreamReader(FilePath, false))
                {
                    int Counter = -1;

                    BasicGroups.Add(new List<Quadruple>());
                    BasicGroups[++Counter] = new List<Quadruple>();

                    while (!SR.EndOfStream)
                    {
                        string[] QuadValues = SR.ReadLine().Split(' ');

                        if (int.Parse(QuadValues[3]) == (int)OperationType.Q_LABEL)
                        {
                            BasicGroups.Add(new List<Quadruple>());
                            BasicGroups[++Counter] = new List<Quadruple>();
                        }

                        Quadruple Quad = new Quadruple();
                        Quad.Result = QuadValues[0];
                        Quad.Src1 = QuadValues[1];
                        Quad.Src2 = QuadValues[2];
                        Quad.Operation = (OperationType)int.Parse(QuadValues[3]);
                        //Quad.BasicGroupNum = Counter;

                        BasicGroups[Counter].Add(Quad);

                        if ((OperationType)int.Parse(QuadValues[3]) == OperationType.Q_JMP)
                        {
                            BasicGroups.Add(new List<Quadruple>());
                            BasicGroups[++Counter] = new List<Quadruple>();
                        }
                    }
                }

                int NumberOfRegisters = 100;
                int RegCounter = -1;
                string FilePathOut = "GeneratedCode.txt";
                Dictionary<int, string> RegisterDescriptor = new Dictionary<int, string>();

                //Remember to update the symbol table
                //Here, we have the quadruples in Basic Groups from above
                using (StreamWriter SW = new StreamWriter(FilePathOut, false))
                {
                    foreach (List<Quadruple> QuadGroup in BasicGroups)
                    {
                        foreach (Quadruple Quad in QuadGroup)  //Handle Quadruple Logic
                        {
                            if (RegCounter >= NumberOfRegisters)
                                throw new Exception("Out Of Registers");
                            RegCounter++;

                            switch (Quad.Operation)
                            {
                                case OperationType.Q_Assign:

                                    string Src1M = Quad.Src1;
                                    if (Quad.Src1[0] == '$')
                                    {
                                        foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                            if (KVP.Value == Quad.Src1)
                                                Src1M = "R" + KVP.Key.ToString();
                                    }

                                    //Check if Result
                                    if (Quad.Result[0] == '$')
                                    {
                                        RegisterDescriptor[RegCounter] = Quad.Result;
                                        SW.WriteLine("MOV " + "R" + RegCounter.ToString() + ", " + Src1M);
                                    }
                                    else
                                    {
                                        RegisterDescriptor[RegCounter] = Quad.Result;
                                        SW.WriteLine("MOV " + "R" + RegCounter.ToString() + ", " + Src1M);
                                        SW.WriteLine("STR " + Quad.Result + ", " + "R" + RegCounter.ToString());
                                    }

                                    break;
                                case OperationType.Q_ADD:

                                    if (Quad.Src1[0] != '$' && Quad.Src2[0] != '$') //Needs Load operation
                                    {
                                        if (int.TryParse(Quad.Src1, out int Val))
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("ADD " + "R" + RegCounter.ToString() + ", " + "R" + PrevReg.ToString() + ", " + Quad.Src2);
                                        }
                                        else
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src2);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("ADD " + "R" + RegCounter.ToString() + ", " + Quad.Src1 + ", " + "R" + PrevReg.ToString());
                                        }
                                    }
                                    else
                                    {

                                        string Src11 = Quad.Src1;
                                        if (Quad.Src1[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src1)
                                                    Src11 = "R" + KVP.Key.ToString();
                                        }

                                        string Src12 = Quad.Src2;
                                        if (Quad.Src2[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src2)
                                                    Src12 = "R" + KVP.Key.ToString();
                                        }

                                        SW.WriteLine("ADD " + Src11 + ", " + Src12);
                                    }

                                    if (Quad.Result[0] != '$')
                                        SW.WriteLine("STR " + Quad.Result + ", " + "R" + RegCounter.ToString());
                                    else
                                        RegisterDescriptor[RegCounter] = Quad.Result;

                                    break;
                                case OperationType.Q_SUB:

                                    if (Quad.Src1[0] != '$' && Quad.Src2[0] != '$') //Needs Load operation
                                    {
                                        if (int.TryParse(Quad.Src1, out int Val))
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + "R" + PrevReg.ToString() + ", " + Quad.Src2);
                                        }
                                        else
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src2);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + Quad.Src1 + ", " + "R" + PrevReg.ToString());
                                        }
                                    }
                                    else
                                    {

                                        string Src11 = Quad.Src1;
                                        if (Quad.Src1[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src1)
                                                    Src11 = "R" + KVP.Key.ToString();
                                        }

                                        string Src12 = Quad.Src2;
                                        if (Quad.Src2[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src2)
                                                    Src12 = "R" + KVP.Key.ToString();
                                        }

                                        SW.WriteLine("SUB " + Src11 + ", " + Src12);
                                    }

                                    if (Quad.Result[0] != '$')
                                        SW.WriteLine("STR " + Quad.Result + ", " + "R" + RegCounter.ToString());
                                    else
                                        RegisterDescriptor[RegCounter] = Quad.Result;

                                    break;
                                case OperationType.Q_MUL:

                                    if (Quad.Src1[0] != '$' && Quad.Src2[0] != '$') //Needs Load operation
                                    {
                                        if (int.TryParse(Quad.Src1, out int Val))
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("MUL " + "R" + RegCounter.ToString() + ", " + "R" + PrevReg.ToString() + ", " + Quad.Src2);
                                        }
                                        else
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src2);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("MUL " + "R" + RegCounter.ToString() + ", " + Quad.Src1 + ", " + "R" + PrevReg.ToString());
                                        }
                                    }
                                    else
                                    {

                                        string Src11 = Quad.Src1;
                                        if (Quad.Src1[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src1)
                                                    Src11 = "R" + KVP.Key.ToString();
                                        }

                                        string Src12 = Quad.Src2;
                                        if (Quad.Src2[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src2)
                                                    Src12 = "R" + KVP.Key.ToString();
                                        }

                                        SW.WriteLine("MUL " + Src11 + ", " + Src12);
                                    }

                                    if (Quad.Result[0] != '$')
                                        SW.WriteLine("STR " + Quad.Result + ", " + "R" + RegCounter.ToString());
                                    else
                                        RegisterDescriptor[RegCounter] = Quad.Result;

                                    break;
                                case OperationType.Q_DIV:

                                    if (Quad.Src1[0] != '$' && Quad.Src2[0] != '$') //Needs Load operation
                                    {
                                        if (int.TryParse(Quad.Src1, out int Val))
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("DIV " + "R" + RegCounter.ToString() + ", " + "R" + PrevReg.ToString() + ", " + Quad.Src2);
                                        }
                                        else
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src2);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("DIV " + "R" + RegCounter.ToString() + ", " + Quad.Src1 + ", " + "R" + PrevReg.ToString());
                                        }
                                    }
                                    else
                                    {

                                        string Src11 = Quad.Src1;
                                        if (Quad.Src1[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src1)
                                                    Src11 = "R" + KVP.Key.ToString();
                                        }

                                        string Src12 = Quad.Src2;
                                        if (Quad.Src2[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src2)
                                                    Src12 = "R" + KVP.Key.ToString();
                                        }

                                        SW.WriteLine("DIV " + Src11 + ", " + Src12);
                                    }

                                    if (Quad.Result[0] != '$')
                                        SW.WriteLine("STR " + Quad.Result + ", " + "R" + RegCounter.ToString());
                                    else
                                        RegisterDescriptor[RegCounter] = Quad.Result;

                                    break;
                                case OperationType.Q_LABEL:

                                    SW.WriteLine(Quad.Result + ":");

                                    break;
                                case OperationType.Q_JMP:

                                    SW.WriteLine("JMP " + Quad.Result);

                                    break;
                                case OperationType.Q_JZ:

                                    string Src1 = Quad.Src1;
                                    if (Quad.Src1[0] == '$')
                                    {
                                        foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                            if (KVP.Value == Quad.Src1)
                                                Src1 = "R" + KVP.Key.ToString();
                                    }

                                    SW.WriteLine("MOV " + "R" + RegCounter.ToString() + ", " + Src1);
                                    SW.WriteLine("CMP " + "R" + RegCounter.ToString() + ", " + "0");
                                    SW.WriteLine("JZ " + Quad.Result);

                                    break;
                                case OperationType.Q_JNZ:

                                    string Src1Z = Quad.Src1;
                                    if (Quad.Src1[0] == '$')
                                    {
                                        foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                            if (KVP.Value == Quad.Src1)
                                                Src1 = "R" + KVP.Key.ToString();
                                    }

                                    SW.WriteLine("MOV " + "R" + RegCounter.ToString() + ", " + Src1Z);
                                    SW.WriteLine("CMP " + "R" + RegCounter.ToString() + ", " + "0");
                                    SW.WriteLine("JNZ " + Quad.Result);

                                    break;
                                case OperationType.Q_GE:

                                    if (Quad.Src1[0] != '$' && Quad.Src2[0] != '$') //Needs Load operation
                                    {
                                        if (int.TryParse(Quad.Src1, out int Val))
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + "R" + PrevReg.ToString() + ", " + Quad.Src2);
                                        }
                                        else
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src2);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + Quad.Src1 + ", " + "R" + PrevReg.ToString());
                                        }
                                    }
                                    else
                                    {

                                        string Src11 = Quad.Src1;
                                        if (Quad.Src1[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src1)
                                                    Src11 = "R" + KVP.Key.ToString();
                                        }

                                        string Src12 = Quad.Src2;
                                        if (Quad.Src2[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src2)
                                                    Src12 = "R" + KVP.Key.ToString();
                                        }

                                        SW.WriteLine("SUB " + Src11 + ", " + Src12);
                                    }

                                    SW.WriteLine("JGE " + Quad.Result);

                                    break;
                                case OperationType.Q_LE:

                                    if (Quad.Src1[0] != '$' && Quad.Src2[0] != '$') //Needs Load operation
                                    {
                                        if (int.TryParse(Quad.Src1, out int Val))
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + "R" + PrevReg.ToString() + ", " + Quad.Src2);
                                        }
                                        else
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src2);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + Quad.Src1 + ", " + "R" + PrevReg.ToString());
                                        }
                                    }
                                    else
                                    {

                                        string Src11 = Quad.Src1;
                                        if (Quad.Src1[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src1)
                                                    Src11 = "R" + KVP.Key.ToString();
                                        }

                                        string Src12 = Quad.Src2;
                                        if (Quad.Src2[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src2)
                                                    Src12 = "R" + KVP.Key.ToString();
                                        }

                                        SW.WriteLine("SUB " + Src11 + ", " + Src12);
                                    }

                                    SW.WriteLine("JLE " + Quad.Result);

                                    break;
                                case OperationType.Q_GT:

                                    if (Quad.Src1[0] != '$' && Quad.Src2[0] != '$') //Needs Load operation
                                    {
                                        if (int.TryParse(Quad.Src1, out int Val))
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + "R" + PrevReg.ToString() + ", " + Quad.Src2);
                                        }
                                        else
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src2);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + Quad.Src1 + ", " + "R" + PrevReg.ToString());
                                        }
                                    }
                                    else
                                    {

                                        string Src11 = Quad.Src1;
                                        if (Quad.Src1[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src1)
                                                    Src11 = "R" + KVP.Key.ToString();
                                        }

                                        string Src12 = Quad.Src2;
                                        if (Quad.Src2[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src2)
                                                    Src12 = "R" + KVP.Key.ToString();
                                        }

                                        SW.WriteLine("SUB " + Src11 + ", " + Src12);
                                    }

                                    SW.WriteLine("JG " + Quad.Result);

                                    break;
                                case OperationType.Q_LT:

                                    if (Quad.Src1[0] != '$' && Quad.Src2[0] != '$') //Needs Load operation
                                    {
                                        if (int.TryParse(Quad.Src1, out int Val))
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + "R" + PrevReg.ToString() + ", " + Quad.Src2);
                                        }
                                        else
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src2);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + Quad.Src1 + ", " + "R" + PrevReg.ToString());
                                        }
                                    }
                                    else
                                    {

                                        string Src11 = Quad.Src1;
                                        if (Quad.Src1[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src1)
                                                    Src11 = "R" + KVP.Key.ToString();
                                        }

                                        string Src12 = Quad.Src2;
                                        if (Quad.Src2[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src2)
                                                    Src12 = "R" + KVP.Key.ToString();
                                        }

                                        SW.WriteLine("SUB " + Src11 + ", " + Src12);
                                    }

                                    SW.WriteLine("JL " + Quad.Result);

                                    break;
                                case OperationType.Q_EQ:

                                    if (Quad.Src1[0] != '$' && Quad.Src2[0] != '$') //Needs Load operation
                                    {
                                        if (int.TryParse(Quad.Src1, out int Val))
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + "R" + PrevReg.ToString() + ", " + Quad.Src2);
                                        }
                                        else
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + Quad.Src2 + ", " + "R" + PrevReg.ToString());
                                        }
                                    }
                                    else
                                    {

                                        string Src11 = Quad.Src1;
                                        if (Quad.Src1[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src1)
                                                    Src11 = "R" + KVP.Key.ToString();
                                        }

                                        string Src12 = Quad.Src2;
                                        if (Quad.Src2[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src2)
                                                    Src12 = "R" + KVP.Key.ToString();
                                        }

                                        SW.WriteLine("SUB " + Src11 + ", " + Src12);
                                    }

                                    if (Quad.Result[0] != '$')
                                        SW.WriteLine("STR " + Quad.Result + ", " + "R" + RegCounter.ToString());
                                    else
                                        RegisterDescriptor[RegCounter] = Quad.Result;

                                    break;
                                case OperationType.Q_NE:

                                    if (Quad.Src1[0] != '$' && Quad.Src2[0] != '$') //Needs Load operation
                                    {
                                        if (int.TryParse(Quad.Src1, out int Val))
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + "R" + PrevReg.ToString() + ", " + Quad.Src2);
                                        }
                                        else
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("SUB " + "R" + RegCounter.ToString() + ", " + Quad.Src2 + ", " + "R" + PrevReg.ToString());
                                        }

                                        SW.WriteLine("NOT " + "R" + RegCounter.ToString());
                                    }
                                    else
                                    {

                                        string Src11 = Quad.Src1;
                                        if (Quad.Src1[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src1)
                                                    Src11 = "R" + KVP.Key.ToString();
                                        }

                                        string Src12 = Quad.Src2;
                                        if (Quad.Src2[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src2)
                                                    Src12 = "R" + KVP.Key.ToString();
                                        }

                                        SW.WriteLine("SUB " + Src11 + ", " + Src12);
                                    }

                                    if (Quad.Result[0] != '$')
                                        SW.WriteLine("STR " + Quad.Result + ", " + "R" + RegCounter.ToString());
                                    else
                                        RegisterDescriptor[RegCounter] = Quad.Result;

                                    break;
                                case OperationType.Q_LOGIC_AND:

                                    if (Quad.Src1[0] != '$' && Quad.Src2[0] != '$') //Needs Load operation
                                    {
                                        if (int.TryParse(Quad.Src1, out int Val))
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("AND " + "R" + RegCounter.ToString() + ", " + "R" + PrevReg.ToString() + ", " + Quad.Src2);
                                        }
                                        else
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("AND " + "R" + RegCounter.ToString() + ", " + Quad.Src2 + ", " + "R" + PrevReg.ToString());
                                        }
                                    }
                                    else
                                    {

                                        string Src11 = Quad.Src1;
                                        if (Quad.Src1[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src1)
                                                    Src11 = "R" + KVP.Key.ToString();
                                        }

                                        string Src12 = Quad.Src2;
                                        if (Quad.Src2[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src2)
                                                    Src12 = "R" + KVP.Key.ToString();
                                        }

                                        SW.WriteLine("AND " + Src11 + ", " + Src12);
                                    }

                                    if (Quad.Result[0] != '$')
                                        SW.WriteLine("STR " + Quad.Result + ", " + "R" + RegCounter.ToString());
                                    else
                                        RegisterDescriptor[RegCounter] = Quad.Result;

                                    break;
                                case OperationType.Q_LOGIC_OR:

                                    if (Quad.Src1[0] != '$' && Quad.Src2[0] != '$') //Needs Load operation
                                    {
                                        if (int.TryParse(Quad.Src1, out int Val))
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("OR " + "R" + RegCounter.ToString() + ", " + "R" + PrevReg.ToString() + ", " + Quad.Src2);
                                        }
                                        else
                                        {
                                            SW.WriteLine("LOD " + "R" + RegCounter.ToString() + ", " + Quad.Src1);
                                            int PrevReg = RegCounter;

                                            RegCounter++;
                                            SW.WriteLine("OR " + "R" + RegCounter.ToString() + ", " + Quad.Src2 + ", " + "R" + PrevReg.ToString());
                                        }
                                    }
                                    else
                                    {

                                        string Src11 = Quad.Src1;
                                        if (Quad.Src1[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src1)
                                                    Src11 = "R" + KVP.Key.ToString();
                                        }

                                        string Src12 = Quad.Src2;
                                        if (Quad.Src2[0] == '$')
                                        {
                                            foreach (KeyValuePair<int, string> KVP in RegisterDescriptor)
                                                if (KVP.Value == Quad.Src2)
                                                    Src12 = "R" + KVP.Key.ToString();
                                        }

                                        SW.WriteLine("OR " + Src11 + ", " + Src12);
                                    }

                                    if (Quad.Result[0] != '$')
                                        SW.WriteLine("STR " + Quad.Result + ", " + "R" + RegCounter.ToString());
                                    else
                                        RegisterDescriptor[RegCounter] = Quad.Result;

                                    break;
                                case OperationType.Q_INC:

                                    SW.WriteLine("INC " + Quad.Result);

                                    break;
                                case OperationType.Q_DEC:

                                    SW.WriteLine("DEC " + Quad.Result);

                                    break;
                                case OperationType.Q_PUSH:

                                    SW.WriteLine("PUSH " + Quad.Result);

                                    break;
                                case OperationType.Q_POP:

                                    SW.WriteLine("POP " + Quad.Result);

                                    break;
                                default:
                                    break;
                            }
                        }
                    }
                }
                return true;
            }
            catch (FileNotFoundException eee) {
                return false;
            }
        }
    }
}
