#ifndef __SYMBOLTABLE_HPP_
#define __SYMBOLTABLE_HPP_

#include <iostream>
#include <string>
#include <cstring>
#include <sstream>
#include <stdio.h>
using namespace std;

#define MAX_SIZE 100 //size of hash table
enum SymbolKind
{
    constant, //const int M
    var,      //int x
    func,     //void main
    param,    //int par
};
enum DataType
{
    TYPE_INT = 10,
    TYPE_DOUBLE,
    TYPE_CHAR,
    TYPE_VOID,
    TYPE_BOOL
};

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
SymbolTableEntry *symbolTable[MAX_SIZE + 1]; //0-MAX-1
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

//insert new entry in symbol table
void insert(string varName, SymbolKind kind, DataType dataType, string value)
{
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
        if (value != "") //empty string indicates NOT Intitialized!
        {
            toInsert->value = value;
            toInsert->initialized = true;
        }
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
                return;
            }
            prev = toInsert;
            toInsert = toInsert->next;
        }
        toInsert = new SymbolTableEntry();
        toInsert->name = varName;
        toInsert->kind = kind;
        toInsert->dataType = dataType;
        if (value != "") //empty string indicates NOT Intitialized!
        {
            toInsert->value = value;
            toInsert->initialized = true;
        }
        prev->next = toInsert;
    }
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

//print the symbol table contents
string printSymbolTable()
{
    stringstream ss;
    for (int i = 0; i < MAX_SIZE; i++)
    {
        SymbolTableEntry *temp = symbolTable[i];
        while (temp != NULL)
        {
            ss << "Name: " << temp->name;
            ss << " - Value: " << temp->value;
            if (temp->kind == var)
            {
                ss << " - Type: var";
            }
            if (temp->dataType == TYPE_INT)
            {
                ss << " - Datatype: INT_TYPE\n";
            }
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