//
//  LevelData.m
//  CandyZuma_Cool
//
//  Created by lion on 9/12/13.
//  Copyright 2013 MingGong. All rights reserved.
//

#import "LevelData.h"

@interface LevelData () <NSXMLParserDelegate>
@end


const float DEF_DEFAULT_WIDTH   =   960;
const float DEF_DEFAULT_HEIGHT   =  640;

@implementation LevelData
{
    NSDateFormatter *_dateFormatter;
    
    BOOL _accumulatingParsedCharacterData;
    BOOL _didAbortParsing;
    NSUInteger _parsedEarthquakesCounter;
}

- (id)initWithXML:(NSURL *)xmlURL WinSize:(CGSize)winSize
{
    self = [super init];
    if (self) {
        m_nLevel = 0;
        m_nrollTo = 0;
        m_nColorCount = 0;
        m_nlPosCount = 0;
        m_bXMLLoaded = false;
        m_winSize = winSize;
        m_levelData = [NSData dataWithContentsOfURL:xmlURL];
    }
    return self;
}

// The main function for this NSOperation, to start the parsing.
- (void)main {
    
    /*
     It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not desirable because it gives less control over the network, particularly in responding to connection errors.
     */
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData: m_levelData];
    [parser setDelegate:self];
    [parser parse];
}

- (int)getLevel
{
    return m_nLevel;
}

- (int)getRollTo
{
    return m_nrollTo;
}

- (CGPoint)getShooterPos
{
    return m_ptShooterPos;
}

- (int)getColorCount
{
    return m_nColorCount;
}

- (int)getColorFromIndex:(int)nIndex
{
    if (nIndex < 0)
        return -1;
    
    if (nIndex >= m_nColorCount)
        return -1;
    
    return m_colorArray[nIndex];
}

- (int)getLocationCount
{
    return m_nlPosCount;
}

- (CGPoint)getPosFromIndex:(int)nIndex
{
    CGPoint pt; pt.x = 0; pt.y = 0;
    if (nIndex < 0)
        return pt;
    
    if (nIndex >= m_nlPosCount)
        return pt;
    
    return m_locationArray[nIndex];
}

- (CGPoint)getStartLineFrom
{
    return m_ptStartLineFrom;
}

- (CGPoint)getStartLineTo
{
    return m_ptStartLineTo;
}

- (bool)isXMLLoaded
{
    return m_bXMLLoaded;
}

static const NSUInteger kMaximumNumberOfPos = 1000;
static NSString * const kLevelElementName = @"info";

#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    /*
     If the number of parsed earthquakes is greater than kMaximumNumberOfEarthquakesToParse, abort the parse.
     */
    if (_parsedEarthquakesCounter >= kMaximumNumberOfPos) {
        /*
         Use the flag didAbortParsing to distinguish between this deliberate stop and other parser errors.
         */
        _didAbortParsing = YES;
        [parser abortParsing];
    }
    if ([elementName isEqualToString:kLevelElementName]) {
        float fRate = m_winSize.height / DEF_DEFAULT_HEIGHT;
        float fOffsetX = (m_winSize.width - DEF_DEFAULT_WIDTH*fRate)/2;
        
        // level info
        NSString *strLevel = [attributeDict valueForKey:@"level"];
        m_nLevel = [strLevel intValue];
        
        // roolTo info
        NSString *strRollTo = [attributeDict valueForKey:@"rollTo"];
        m_nrollTo = [strRollTo intValue];
        
        // shooterPos info
        NSString *strShooterPos = [attributeDict valueForKey:@"shooterPos"];
        NSArray* posArray = [strShooterPos componentsSeparatedByCharactersInSet:NSCharacterSet.punctuationCharacterSet];
        NSString *strXPos = posArray[0];
        NSString *strYPos = posArray[1];
        m_ptShooterPos.x = [strXPos intValue]*fRate+fOffsetX;
        m_ptShooterPos.y = (DEF_DEFAULT_HEIGHT-[strYPos floatValue])*fRate;
        
        // colorArray info
        NSString *strcolorArr = [attributeDict valueForKey:@"colorArr"];
        NSArray* colorArray = [strcolorArr componentsSeparatedByCharactersInSet:NSCharacterSet.punctuationCharacterSet];
        m_nColorCount = [colorArray count];
        for (int i = 0; i < m_nColorCount; i++)
        {
            NSString* strOneColor = colorArray[i];
            m_colorArray[i] = [strOneColor intValue];
        }
        
        // startline
        NSString *strStartLineArr = [attributeDict valueForKey:@"startline"];
        NSArray* lineArray = [strStartLineArr componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        if ([lineArray count] == 4)
        {
            NSString* strOnePos = lineArray[0];
            m_ptStartLineFrom.x = [strOnePos floatValue]*fRate+fOffsetX;
            strOnePos = lineArray[1];
            m_ptStartLineFrom.y = (DEF_DEFAULT_HEIGHT-[strOnePos floatValue])*fRate;
            strOnePos = lineArray[2];
            m_ptStartLineTo.x = [strOnePos floatValue]*fRate+fOffsetX;
            strOnePos = lineArray[3];
            m_ptStartLineTo.y = (DEF_DEFAULT_HEIGHT-[strOnePos floatValue])*fRate;
        }
        
        m_nColorCount = [colorArray count];
        for (int i = 0; i < m_nColorCount; i++)
        {
            NSString* strOneColor = colorArray[i];
            m_colorArray[i] = [strOneColor intValue];
        }
        
        // location info
        NSString *strDataArr = [attributeDict valueForKey:@"data"];
        NSArray* dataArray = [strDataArr componentsSeparatedByCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        m_nlPosCount = [dataArray count];
        for (int i = 0; i < m_nlPosCount; i++)
        {
            NSString* strOnePos = dataArray[i];
            if (i % 2 == 0)
            {
                m_locationArray[i/2].x = [strOnePos floatValue]*fRate+fOffsetX;
            }
            else
            {
                m_locationArray[i/2].y = (DEF_DEFAULT_HEIGHT-[strOnePos floatValue])*fRate;
            }
        }
        
        m_nlPosCount /= 2;
        
        m_bXMLLoaded = true;

    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
/*
    if ([elementName isEqualToString:kEntryElementName]) {
        
        [self.currentParseBatch addObject:self.currentEarthquakeObject];
        _parsedEarthquakesCounter++;
        if ([self.currentParseBatch count] >= kSizeOfEarthquakeBatch) {
            [self performSelectorOnMainThread:@selector(addEarthquakesToList:) withObject:self.currentParseBatch waitUntilDone:NO];
            self.currentParseBatch = [NSMutableArray array];
        }
    }
    else if ([elementName isEqualToString:kTitleElementName]) {
        NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        // Scan past the "M " before the magnitude.
        if ([scanner scanString:@"M " intoString:NULL]) {
            CGFloat magnitude;
            if ([scanner scanFloat:&magnitude]) {
                self.currentEarthquakeObject.magnitude = magnitude;
                // Scan past the ", " before the title.
                if ([scanner scanString:@", " intoString:NULL]) {
                    NSString *location = nil;
                    // Scan the remainer of the string.
                    if ([scanner scanUpToCharactersFromSet:
                         [NSCharacterSet illegalCharacterSet] intoString:&location]) {
                        self.currentEarthquakeObject.location = location;
                    }
                }
            }
        }
    }
    else if ([elementName isEqualToString:kUpdatedElementName]) {
        if (self.currentEarthquakeObject != nil) {
            self.currentEarthquakeObject.date = [_dateFormatter dateFromString:self.currentParsedCharacterData];
        }
        else {
            // kUpdatedElementName can be found outside an entry element (i.e. in the XML header)
            // so don't process it here.
        }
    }
    else if ([elementName isEqualToString:kGeoRSSPointElementName]) {
        // The georss:point element contains the latitude and longitude of the earthquake epicenter.
        // 18.6477 -66.7452
        //
        NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        double latitude, longitude;
        if ([scanner scanDouble:&latitude]) {
            if ([scanner scanDouble:&longitude]) {
                self.currentEarthquakeObject.latitude = latitude;
                self.currentEarthquakeObject.longitude = longitude;
            }
        }
    }
    // Stop accumulating parsed character data. We won't start again until specific elements begin.
    _accumulatingParsedCharacterData = NO;*/
}

/**
 This method is called by the parser when it find parsed character data ("PCDATA") in an element. The parser is not guaranteed to deliver all of the parsed character data for an element in a single invocation, so it is necessary to accumulate character data until the end of the element is reached.
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    /*
    if (_accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        //
        [self.currentParsedCharacterData appendString:string];
    }*/
}

/**
 An error occurred while parsing the earthquake data: post the error as an NSNotification to our app delegate.
 */
- (void)handleXMLError:(NSError *)parseError {
}

/**
 An error occurred while parsing the earthquake data, pass the error to the main thread for handling.
 (Note: don't report an error if we aborted the parse due to a max limit of earthquakes.)
 */
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !_didAbortParsing) {
        [self performSelectorOnMainThread:@selector(handleXMLError:) withObject:parseError waitUntilDone:NO];
    }
}

@end
