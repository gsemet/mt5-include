//+------------------------------------------------------------------+
//|                                             MoneyFixedMargin.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertMoney.mqh>

// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Trading with fixed margin                                  |
//| Type=Money                                                       |
//| Name=FixMargin                                                   |
//| Class=CMoneyNoLose                                          |
//| Page=                                                            |
//| Parameter=Percent,double,10.0,Percentage of margin               |
//+------------------------------------------------------------------+

// wizard description end

//+------------------------------------------------------------------+
//| Class CMoneyNoLose.                                         |
//| Purpose: Class of money management with fixed percent margin.    |
//|              Derives from class CExpertMoney.                    |
//+------------------------------------------------------------------+
class CMoneyNoLose : public CExpertMoney
{
    public:
                         CMoneyNoLose(void);
                        ~CMoneyNoLose(void);
       //---
       virtual double    CheckOpenLong(double price,double sl);
       virtual double    CheckOpenShort(double price,double sl);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CMoneyNoLose::CMoneyNoLose(void)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void CMoneyNoLose::~CMoneyNoLose(void)
{
}

//+------------------------------------------------------------------+
//| Getting lot size for open long position.                         |
//+------------------------------------------------------------------+
double CMoneyNoLose::CheckOpenLong(double price, double sl)
{
    if (m_symbol == NULL)
    {
        return(0.0);
    }
    
    //--- select lot size
    double lot;
    if (price == 0.0)
    {
        lot = m_account.MaxLotCheck(m_symbol.Name(), ORDER_TYPE_BUY, m_symbol.Ask(), m_percent);
    }
    else
    {
        lot = m_account.MaxLotCheck(m_symbol.Name(), ORDER_TYPE_BUY, price, m_percent);
    }
    
    printf(__FUNCTION__ + "check open long lot = " + lot);
    //--- return trading volume
    return(lot);
}

//+------------------------------------------------------------------+
//| Getting lot size for open short position.                        |
//+------------------------------------------------------------------+
double CMoneyNoLose::CheckOpenShort(double price, double sl)
{
    if (m_symbol == NULL)
    {
        return(0.0);
    }
    
    //--- select lot size
    double lot;
    if (price == 0.0)
    {
        lot = m_account.MaxLotCheck(m_symbol.Name(), ORDER_TYPE_SELL, m_symbol.Bid(), m_percent);
    }
    else
    {
        lot = m_account.MaxLotCheck(m_symbol.Name(), ORDER_TYPE_SELL, price,m_percent);
    }
    
    printf(__FUNCTION__ + "check open long lot = " + lot);
    //--- return trading volume
    return(lot);
}
//+------------------------------------------------------------------+
