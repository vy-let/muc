# Prologue

You shouldn’t measure software in terms of Lines Of Code. That makes no sense. You know why:

    #import <Foundation/Foundation.h>
    
    int main() {  @autoreleasepool {
        NSLog(@"Doing nothing for %ds.", ((long)[[NSDate date] timeIntervalSince1970]) % 9200);
        return 0;
    }}

5 SLOC, versus with some whitespace added:

    #import <Foundation/Foundation.h>
    
    int main() {
        @autoreleasepool {
            
            NSLog(@"Doing nothing for %ds.",
                ( (long)[[NSDate date]
                         timeIntervalSince1970] )
                    % 9200
            );
            return 0;
            
        }
    }

11 SLOC, about double for the exact same code.



# MUC

The *Meaningful Unit of Code,* or *muc,* is defined as one-tenth the number of bytes, as compressed by bzip2 at its best compression level, of the source code without its whitespace. Compression headers are not counted.\*

For comparison, both examples above have 11.8 muc. They’re the same by definition: whitespace is stripped in advance. Let’s compare to a more distinct revision:

    #import <Foundation/Foundation.h>
    
    int main() {
        @autoreleasepool {
            
            NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        
            NSLog(@"Doing nothing for %ds.",
                ( (long) currentTime ) % 9200
            );
            return 0;
            
        }
    }

That’s 13.5 muc for functionally identical code. Ideally, perhaps they should be the same, but that would require compiling the code or similar. The extra 1.7 comes from the assignment to a variable; you decide whether this feels faithful to the added complexity of the program.

\* 50 bytes are subtracted from what the compressor outputs, to discount the header data. From the bzip2 manpage:

>   …the compression mechanism has a constant overhead in the region of 50 bytes.



## What it solves

Muc avoids:

+ whitespace-related ambiguities found in SLOC.
+ over-counting repetitive phrases found in verbose languages.
+ over-counting repetitive phrases found in redundant commenting formats.

## What it does not solve

Muc does not:

+ address the usefulness of comments. Essentially, concise comments are deemed meaningful to the code.
+ address the actual usefulness of code. If it could, perhaps we could also determine whether it halts…
+ account for differences in the amount of boilerplate code required in different languages.



## Considerations

When measuring a project’s muc, the whole is less than the sum of its parts. That is to say, all project source files should be concatenated and considered at once for compressing, rather than compressing each individually and adding together the muc for each file.

Imagine your project contains two virtually-identical files. The second doesn’t add much meaning over the first, apart from a few differences. Say they have 102.0 and 102.5 muc, respectively. Taken together, they might contribute only 109 to the project, where, taken individually, they would add an artificially-high 204.5. (Why, you might ask, should we have virtually identical files? We shouldn’t; but copy-pasta inevitably shows up across files, and should not be over-counted.)

**The reference ruby tool currently follows this guideline, and concatenates for itself all the given files.**



# MUC Ruby Reference Tool

…requires Ruby 2 and bzip2 to be installed and console-runnable. It is in beta, and is not guaranteed to work correctly in all situations.

To run, make sure `muc.rb` or a symlink thereto is in your Path, and do

    muc.rb file
    muc.rb file1 file2 file3...
    muc.rb *.m
    cat box | muc.rb



## Changes

- **Version 2:**
    - Ruby tool now properly concatenates the input files.
    - Also uses stdin, if no files are explicitly given.
    - Gives usage guide when appropriate.


