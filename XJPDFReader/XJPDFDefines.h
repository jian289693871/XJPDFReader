//
//  PDFDefines.h
//  PDF
//
//  Created by xuejian on 2018/6/28.
//  Copyright © 2018年 xuejian. All rights reserved.
//

#ifndef XJPDFDefines_h
#define XJPDFDefines_h

#ifdef DEBUG
#define XJPDFLog(...) NSLog(__VA_ARGS__)
#else
#define XJPDFLog(...) do { } while (0)
#endif


#endif /* PDFDefines_h */
