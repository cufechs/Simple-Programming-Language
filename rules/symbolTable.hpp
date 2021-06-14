#ifndef __SYMBOLTABLE_HPP_
#define __SYMBOLTABLE_HPP_

#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
#include <sstream>
#include <stdio.h>
#include "utils.h"
using namespace std;

ofstream myfile3;

#define MAX_SIZE 100 //size of hash table

struct SymbolTableEntry
{
    string name;
    SymbolKind kind;
    DataType dataType;
    bool initialized = false;
    string value; //making the value of any type as a string and then cast it according to the type in code generation..
    SymbolTableEntry *next = NULL;
    SymbolTableEntry()
    {
    }
};

///Symbol table -> hashtable
SymbolTableEntry *symbolTable[MAX_SIZE]; //0-MAX-1
//symbolTable[MAX_SIZE] -> temp

//hash function
int hashFunc(char *str)
{
    unsigned long hash = 5381;
    int c;

    while (c = *str++)
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */

    return hash % MAX_SIZE;
}

//get dataatype from its char*
DataType getDataTypeInsert(string dt)
{
    if (dt == "void")
        return TYPE_VOID;
    if (dt == "int")
        return TYPE_INT;
    if (dt == "double")
        return TYPE_DOUBLE;
    if (dt == "char")
        return TYPE_CHAR;
    if (dt == "string")
        return TYPE_STRING;
    if (dt == "bool")
        return TYPE_BOOL;
}

//insert new entry in symbol table
bool insert(string varName, SymbolKind kind, char *dt, bool initialized, string value = "")
{
    DataType dataType = getDataTypeInsert(dt);

    char *name = new char[varName.length() + 1];
    strcpy(name, varName.c_str());
    int hashValue = hashFunc(name);
    SymbolTableEntry *toInsert = symbolTable[hashValue];
    if (toInsert == NULL) //head is NULL
    {
        toInsert = new SymbolTableEntry();
        toInsert->name = varName;
        toInsert->kind = kind;
        toInsert->dataType = dataType;
        toInsert->initialized = initialized;

        symbolTable[hashValue] = toInsert;
    }
    else
    {
        SymbolTableEntry *prev = toInsert;
        while (toInsert != NULL) //go to the entry that is empty
        {
            //check if this varName is already exists:
            if (varName == toInsert->name)
            {
                //cout << varName << " -> Already exists" << endl;
                return false;
            }
            prev = toInsert;
            toInsert = toInsert->next;
        }
        toInsert = new SymbolTableEntry();
        toInsert->name = varName;
        toInsert->kind = kind;
        toInsert->dataType = dataType;
        toInsert->initialized = initialized;

        prev->next = toInsert;
    }
    return true;
}

//get entry of given var
SymbolTableEntry *getEntry(string varName)
{
    char *name = new char[varName.length() + 1];
    strcpy(name, varName.c_str());
    int hashValue = hashFunc(name);
    SymbolTableEntry *toUpdate = symbolTable[hashValue];
    if (toUpdate == NULL)
    {
        //cout << varName << " -> Doesn't exist" << endl;
        return NULL;
    }
    bool notExist = false;
    while (toUpdate != NULL)
    {
        //check if this varName do exist:
        if (varName == toUpdate->name)
        {
            notExist = true;
            break;
        }
        toUpdate = toUpdate->next;
    }
    if (!notExist)
    {
        //cout << varName << " -> Doesn't exist" << endl;
        return NULL;
    }
    return toUpdate;
}

//update an entry in symbol table
void update(string varName, const char *value)
{
    SymbolTableEntry *toUpdate = getEntry(varName);
    if (toUpdate == NULL)
        return;
    //now we can update:
    toUpdate->value = value;
    if (!toUpdate->initialized)
        toUpdate->initialized = true;
}

void clearSymbolTable()
{
    for (int i = 0; i < MAX_SIZE; i++)
    {
        symbolTable[i] = NULL;
    }
}
string printKind(SymbolKind kind)
{
    if (kind == var)
    {
        return " - Type: var";
    }
    if (kind == constant)
    {
        return " - Type: constant";
    }
    if (kind == func)
    {
        return " - Type: func";
    }
    if (kind == param)
    {
        return " - Type: param";
    }
}
string printType(DataType type)
{
    if (type == TYPE_INT)
    {
        return " - Type: TYPE_INT";
    }
    if (type == TYPE_DOUBLE)
    {
        return " - Type: TYPE_DOUBLE";
    }
    if (type == TYPE_CHAR)
    {
        return " - Type: TYPE_CHAR";
    }
    if (type == TYPE_VOID)
    {
        return " - Type: TYPE_VOID";
    }
    if (type == TYPE_BOOL)
    {
        return " - Type: TYPE_BOOL";
    }
    if (type == TYPE_STRING)
    {
        return " - Type: TYPE_STRING";
    }
}

//print the symbol table contents
string printSymbolTable()
{
    stringstream ss;
    myfile3.open("symbols.txt");
    for (int i = 0; i < MAX_SIZE; i++)
    {
        SymbolTableEntry *temp = symbolTable[i];
        while (temp != NULL && temp->name != "main")
        {

            myfile3 << "Name: " << temp->name;
            if (temp->value != "")
                myfile3 << " - Value: " << temp->value;
            myfile3 << printKind(temp->kind);
            myfile3 << printType(temp->dataType);
            myfile3 << " - Initialized: " << temp->initialized << "\n";
            ///
            ss << "Name: " << temp->name;
            if (temp->value != "")
                ss << " - Value: " << temp->value;
            ss << printKind(temp->kind);
            ss << printType(temp->dataType);
            ss << " - Initialized: " << temp->initialized << "\n";

            temp = temp->next;
        }
    }
    return ss.str();
}

//  Setters and Getters  //
/*
    To get any getter:
        SymbolTableEntry *entry = getEntry(varName);
        if entry is null so entry not exist
        else pass this entry to the getter
*/

//initialized or not
bool getInitializationStatus(SymbolTableEntry *entry)
{
    return entry->initialized;
}
//get value
string getValue(SymbolTableEntry *entry)
{
    return entry->value;
}
//get datatype
DataType getDatatype(SymbolTableEntry *entry)
{
    return entry->dataType;
}
//get symbol kind
SymbolKind getKind(SymbolTableEntry *entry)
{
    return entry->kind;
}

#endif