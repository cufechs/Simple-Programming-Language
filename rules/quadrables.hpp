#ifndef __QUAD_H_
#define __QUAD_H_

#include <iostream>
#include <fstream>
#include "Node.hpp"

std::ofstream myfile2;

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
};

OperationType getOper(std::string opr)
{
    if (opr == "=")
    {
        return Q_Assign;
    }
    if (opr == "+")
    {
        return Q_ADD;
    }
    if (opr == "-")
    {
        return Q_SUB;
    }
    if (opr == "*")
    {
        return Q_MUL;
    }
    if (opr == "/")
    {
        return Q_DIV;
    }
    if (opr == ">")
    {
        return Q_GT;
    }
    if (opr == "<")
    {
        return Q_LT;
    }
    if (opr == "<=")
    {
        return Q_LE;
    }
    if (opr == ">=")
    {
        return Q_GE;
    }
    if (opr == "==")
    {
        return Q_EQ;
    }
    if (opr == "!=")
    {
        return Q_NE;
    }
    if (opr == "&&")
    {
        return Q_LOGIC_AND;
    }
    if (opr == "||")
    {
        return Q_LOGIC_OR;
    }
    if (opr == "JMP")
    {
        return Q_JMP;
    }
    if (opr == "JZ")
    {
        return Q_JZ;
    }
    if (opr == "JNZ")
    {
        return Q_JNZ;
    }
    if (opr == "LABEL")
    {
        return Q_LABEL;
    }
    if (opr == "++")
    {
        return Q_INC;
    }
    if (opr == "--")
    {
        return Q_DEC;
    }
    if (opr == "push")
    {
        return Q_PUSH;
    }
    if (opr == "pop")
    {
        return Q_POP;
    }
}

struct Quadruple
{
    Quadruple() {}
    char *Result;
    char *Src1;
    char *Src2;
    enum OperationType Operation;
    int endFor = false;
    Quadruple *next = NULL;
};

Quadruple *start = NULL;

void insertQuad(char *n1, char *n2, std::string opr, char *tempName, int endFor = 0)
{
    //start->Result = new char[10];
    if (start == NULL)
    {
        start = new Quadruple();
        start->Result = tempName;
        if (n1 != NULL)
            start->Src1 = n1;
        else
            start->Src1 = "#";
        //else
        //start->Src1 = n1->idVal;
        if (n2 != NULL)
            start->Src2 = n2;
        else
            start->Src2 = "#";

        start->Operation = getOper(opr);
        start->endFor = endFor;
    }
    else
    {
        Quadruple *temp = start;
        Quadruple *prev = start;
        while (temp != NULL)
        {
            prev = temp;
            temp = temp->next;
        }
        temp = new Quadruple();
        prev->next = temp;
        temp->Result = tempName;
        if (n1 != NULL)
            temp->Src1 = n1;
        else
            temp->Src1 = "#";
        if (n2 != NULL)
            temp->Src2 = n2;
        else
            temp->Src2 = "#";
        temp->Operation = getOper(opr);
        temp->endFor = endFor;
    }
}

void reArrange()
{
    Quadruple *curr = start;
    Quadruple *tempHead = NULL;
    Quadruple *temp = NULL;
    Quadruple *last = NULL;

    while (curr != NULL)
    {
        if (curr->endFor == 1)
        {
            if (temp == NULL)
            {
                temp = new Quadruple();
                temp->Result = curr->Result;
                temp->Src1 = curr->Src1;
                temp->Src2 = curr->Src2;
                temp->Operation = curr->Operation;
                temp->endFor = curr->endFor;
                temp->next = NULL;
                tempHead = temp;
            }
            else
            {
                while (temp->next != NULL)
                {
                    temp = temp->next;
                }
                temp->next = new Quadruple();
                temp->next->Result = curr->Result;
                temp->next->Src1 = curr->Src1;
                temp->next->Src2 = curr->Src2;
                temp->next->Operation = curr->Operation;
                temp->next->endFor = curr->endFor;
                temp->next->next = NULL;
            }
        }
        if (curr->next != NULL && curr->next->endFor == -1)
        {
            last = curr;
        }
        curr = curr->next;
    }
    curr = start;
    while (curr->next != NULL)
    {
        if (curr->next->endFor == 1)
        {
            curr->next = curr->next->next;
            if (curr->next == NULL)
                break;
        }
        else
            curr = curr->next;
    }
    // printf("last: %s , %d \n", last->Result, last->Operation);
    // while (temp != NULL)
    // {
    //     printf("temp: %s , %d \n", temp->Result, temp->Operation);
    //     temp = temp->next;
    // }
    if (tempHead != NULL)
    {
        Quadruple *last2 = last->next;
        last->next = tempHead;
        temp = tempHead;
        while (temp->next != NULL)
            temp = temp->next;
        temp->next = last2;
    }
}

void printQuadrables()
{
    reArrange();
    myfile2.open("quad.txt");
    Quadruple *temp = start;
    while (temp != NULL)
    {
        printf("result = %s , src1 = %s , src2 = %s opr = %d  forend = %d\n", temp->Result, temp->Src1, temp->Src2, temp->Operation, temp->endFor);
        myfile2 << temp->Result << " " << temp->Src1 << " " << temp->Src2 << " " << temp->Operation << "\n";
        temp = temp->next;
    }
}

#endif