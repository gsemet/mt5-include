//+------------------------------------------------------------------+
//|                                               TrailingNoLose.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertTrailing.mqh>

// wizard description start
//+----------------------------------------------------------------------+
//| Description of the class                                             |
//| Title=Trailing Stop based on allowed retracement level               |
//| Type=Trailing                                                        |
//| Name=NoLose                                                          |
//| Class=CTrailingNoLose                                                |
//| Page=                                                                |
//| Parameter=StopLevel,int,20,Initial Stop Loss                         |
//| Parameter=ThresholdRetracement,int,20,Min threshold before triggering retracement mecanism (in point)|
//| Parameter=RetracementPercent,int,50,Allowed retracement after threshold|
//+----------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CTrailingNoLose.                                        |
//| Purpose: Class of trailing stop that allows a certain retracement |
//|              It also prevent as must as possible to lose money           |
//|              Derives from class CExpertTrailing.                 |
//+------------------------------------------------------------------+

class CTrailingNoLose : public CExpertTrailing
{
    protected:
         //--- input parameters
        int               m_stop_level;
        int               m_retracement_threshold;
        int               m_allowed_retracement_percent;
        int               m_max_previous_value;
        int               m_inp_signal_min_win;
    
    public:
                          CTrailingNoLose(void);
                         ~CTrailingNoLose(void);
                        
        //--- methods of initialization of protected data
        void              StopLevel(int stop_level)     
        {
            m_stop_level = stop_level;
        };

        void              RetracementThreshold(int threshold)
        {
            m_retracement_threshold = threshold;
        };

        void              AllowedRetracement(int allowed_retracement)
        {
            m_allowed_retracement_percent = allowed_retracement;
        };

        void              MinWin(int inp_signal_min_win)
        {
            m_inp_signal_min_win = inp_signal_min_win;
        };

        virtual bool      ValidationSettings(void);
        //---
        virtual bool      CheckTrailingStopLong(CPositionInfo *position, double &sl, double &tp);
        virtual bool      CheckTrailingStopShort(CPositionInfo *position, double &sl, double &tp);
};
  
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CTrailingNoLose::CTrailingNoLose(void) : m_stop_level(30),
                                              m_retracement_threshold(20),
                                              m_allowed_retracement_percent(50),
                                              m_max_previous_value(0),
                                              m_inp_signal_min_win(0)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTrailingNoLose::~CTrailingNoLose(void)
{
}

//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CTrailingNoLose::ValidationSettings(void)
{
    if (!CExpertTrailing::ValidationSettings())
        return(false);
 
    //--- initial data checks
    if (m_retracement_threshold <= 0)
    {
        printf(__FUNCTION__ + ": retracement threshold should be greater than 0");
        return(false);
    }
    if (m_retracement_threshold * (m_adjusted_point / m_symbol.Point()) < m_symbol.StopsLevel())
    {
        printf(__FUNCTION__ + ": invalid retracement level: " + m_retracement_threshold);
        return(false);
    }
    if (m_inp_signal_min_win <= 0)
    {
        printf(__FUNCTION__ + ": min win cannot be negative");
        return(false);
    }
     
    if (m_stop_level!=0 && m_stop_level * (m_adjusted_point / m_symbol.Point()) < m_symbol.StopsLevel())
    {
        printf(__FUNCTION__ + ": trailing Stop Level must be 0 or greater than %d", m_symbol.StopsLevel());
        return(false);
    }
    
    if (m_allowed_retracement_percent <= 0 || m_allowed_retracement_percent >= 100 )
    {
        printf(__FUNCTION__ + ": Allowe retracement should be between 0 and 100");
        return(false);
    }
    
    //--- ok
    return(true);
}

//+------------------------------------------------------------------+
//| Checking trailing stop and/or profit for long position.          |
//+------------------------------------------------------------------+
bool CTrailingNoLose::CheckTrailingStopLong(CPositionInfo *position, double &sl, double &tp)
{
    //--- check
    if (position == NULL)
        return(false);
    if (m_stop_level == 0)
        return(false);
        
    //---
    double delta;
    double pos_sl = position.StopLoss();
    double base   = (pos_sl == 0.0) ? position.PriceOpen() : pos_sl;
    double price  = m_symbol.Bid();
    
    if (m_max_previous_value < price)
        m_max_previous_value = price;
    
    //---
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    delta = m_stop_level * m_adjusted_point;

    if (price - base > m_inp_signal_min_win + 20 && sl < base)
    {
        printf(__FUNCTION__ + " we won more than twice the min win (" + m_inp_signal_min_win +
               "), we set the stop loss to never lose money !" );
        sl = base + m_inp_signal_min_win;
    }
    
    if (price - base > delta)
    {
        printf(__FUNCTION__ + "price " + price + " - base " + base + " > delta " + delta);
        sl = price - delta;
        //if (m_retracement_threshold != 0)
        //     tp = price + m_retracement_threshold * m_adjusted_point;
        printf(__FUNCTION__ + " tp " + tp + " sl " + sl);
    }
    
    //---
    return (sl != EMPTY_VALUE);
}

//+------------------------------------------------------------------+
//| Checking trailing stop and/or profit for short position.         |
//+------------------------------------------------------------------+
bool CTrailingNoLose::CheckTrailingStopShort(CPositionInfo *position, double &sl, double &tp)
{
    //--- check
    if (position == NULL)
        return(false);
    if (m_stop_level == 0)
        return(false);

    //---
    double delta;
    double pos_sl = position.StopLoss();
    double base  = (pos_sl == 0.0) ? position.PriceOpen() : pos_sl;
    double price = m_symbol.Ask();
    
    if (m_max_previous_value > price)
        m_max_previous_value = price;
        
    //---
    sl = EMPTY_VALUE;
    tp = EMPTY_VALUE;
    delta = m_stop_level * m_adjusted_point;
    
    if (base - price > 2 * m_inp_signal_min_win && sl > base)
    {
        printf(__FUNCTION__ + " we won more than twice the min win (" + m_inp_signal_min_win +
               "), we set the stop loss to never lose money !" );
        sl = base - m_inp_signal_min_win;
    }
    
    if(base - price > delta)
    {
        printf(__FUNCTION__ + "price " + price + " - base " + base + " > delta " + delta);
        sl = price + delta;
        //if (m_retracement_threshold != 0)
        //    tp = price - m_retracement_threshold * m_adjusted_point;
        printf(__FUNCTION__ + " tp " + tp + " sl " + sl);
    }
    
    //---
    return (sl != EMPTY_VALUE);
}
//+------------------------------------------------------------------+
