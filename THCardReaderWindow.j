/*
 * THCardReaderWindow.j
 * InventorySystem
 *
 * Created by Tim Howell on October 12, 2013.
 * Copyright 2013, R.W. Elephant Inc, All rights reserved.
 */

@implementation THCardReaderWindow : CPWindow
{
    CPMutableArray eventQueue;
    CPMutableArray keyDownQueue;
    
    id cardReaderDelegate @accessors;
        
    id keyPressTimeout;
    id keyboardFilter;
}

- (void)awakeFromCib
{
    keyDownQueue = [[CPMutableArray alloc] init];
    eventQueue = [[CPMutableArray alloc] init];
    
    keyboardFilter = function(e){
        
        e.preventDefault();
        
        var code;
    	if (!e) var e = window.event;
    	if (e.keyCode) code = e.keyCode;
    	else if (e.which) code = e.which;
    	var character = String.fromCharCode(code);
                
        var skipFiltering = [eventQueue containsObjectIdenticalTo:e];
        
        if (skipFiltering){
            if ([[self firstResponder] respondsToSelector:@selector(insertText:)]){
                var domElement = [[self firstResponder] _inputElement];
                var oldText = domElement.value;
                    var insertPosition = domElement.selectionStart;
                    
                    preText = oldText.substring(0, insertPosition);
                    postText = oldText.substring(domElement.selectionEnd, oldText.length);
                    domElement.value = preText + character + postText;
                    domElement.setSelectionRange(insertPosition + 1, insertPosition + 1);
            }
            return;
        }
              
        [eventQueue addObject:e];      
        [keyDownQueue addObject:character];
                
        clearTimeout(keyPressTimeout);
        keyPressTimeout = window.setTimeout(function(){
            if ([keyDownQueue count] > 1){
                var completedString = keyDownQueue.join('');
                if ([cardReaderDelegate respondsToSelector:@selector(parseCardData:)]){
                    [cardReaderDelegate parseCardData:completedString];
                }
                [keyDownQueue removeAllObjects];
            }else{
                e.target.dispatchEvent(e);
                [keyDownQueue removeAllObjects];
            }
        }, 40);
    
    }

}

- (void)makeKeyAndOrderFront:(id)aSender
{
    window.addEventListener("keypress", keyboardFilter, false);
    [super makeKeyAndOrderFront:aSender];
}

- (void)performClose:(id)aSender
{
    window.removeEventListener("keypress", keyboardFilter, false);
    [super performClose:aSender];
}

- (void)orderOut:(id)aSender
{
    window.document.removeEventListener("keydown", keyboardFilter, false);
    [super orderOut:aSender];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end
