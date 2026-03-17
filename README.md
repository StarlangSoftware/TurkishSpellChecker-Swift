Turkish Spell Checker
============

This tool is a spelling checker for Modern Turkish. It detects spelling errors and corrects them appropriately, through its list of misspellings and matching to the Turkish dictionary.

Simple Web Interface
============

[Link 1](http://104.247.163.162/nlptoolkit/turkish-spell-checker.html) [Link 2](https://starlangsoftware.github.io/nlptoolkit-web-simple/turkish-spell-checker.html)

Video Lectures
============

[<img src="https://github.com/StarlangSoftware/TurkishSpellChecker/blob/master/video.jpg" width="50%">](https://youtu.be/wKwTKv6Jlo0)

For Developers
============

You can also see [Java](https://github.com/starlangsoftware/TurkishSpellChecker), [Python](https://github.com/starlangsoftware/TurkishSpellChecker-Py), [Cython](https://github.com/starlangsoftware/TurkishSpellChecker-Cy), [C++](https://github.com/starlangsoftware/TurkishSpellChecker-CPP), [C](https://github.com/starlangsoftware/TurkishSpellChecker-C), [Js](https://github.com/starlangsoftware/TurkishSpellChecker-Js), or [C#](https://github.com/starlangsoftware/TurkishSpellChecker-CS) repository.

## Requirements

* Xcode Editor
* [Git](#git)

### Git

Install the [latest version of Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

## Download Code

In order to work on code, create a fork from GitHub page. 
Use Git for cloning the code to your local or below line for Ubuntu:

	git clone <your-fork-git-link>

A directory called TurkishSpellChecker-Swift will be created. Or you can use below link for exploring the code:

	git clone https://github.com/starlangsoftware/TurkishSpellChecker-Swift.git

## Open project with XCode

To import projects from Git with version control:

* XCode IDE, select Clone an Existing Project.

* In the Import window, paste github URL.

* Click Clone.

Result: The imported project is listed in the Project Explorer view and files are loaded.


## Compile

**From IDE**

After being done with the downloading and opening project, select **Build** option from **Product** menu. After compilation process, user can run TurkishSpellChecker-Swift.

For Developers
============

+ [Creating SpellChecker](#creating-spellchecker)
+ [Spell Correction](#spell-correction)

## Creating SpellChecker

SpellChecker finds spelling errors and corrects them in Turkish. There are two types of spell checker available:

* `SimpleSpellChecker`
    
    * To instantiate this, a `FsmMorphologicalAnalyzer` is needed. 
        
            let fsm = FsmMorphologicalAnalyzer()
            let spellChecker = SimpleSpellChecker(fsm);  
     
* `NGramSpellChecker`,
    
    * To create an instance of this, both a `FsmMorphologicalAnalyzer` and a `NGram` is required. 
    
    * `FsmMorphologicalAnalyzer` can be instantiated as follows:
        
            let fsm = FsmMorphologicalAnalyzer()
    
    * `NGram` can be either trained from scratch or loaded from an existing model.
        
        * Training from scratch:
                
                let corpus = Corpus("corpus.txt")
                let ngram = NGram(corpus.getAllWordsAsArrayList(), 1)
                ngram.calculateNGramProbabilities(LaplaceSmoothing())
                
        *There are many smoothing methods available. For other smoothing methods, check [here](https://github.com/olcaytaner/NGram).*       
        * Loading from an existing model:
     
                let ngram = NGram("ngram.txt")

	*For further details, please check [here](https://github.com/starlangsoftware/NGram).*        
            
    * Afterwards, `NGramSpellChecker` can be created as below:
        
            let spellChecker = NGramSpellChecker(fsm, ngram)
     

## Spell Correction

Spell correction can be done as follows:

    let sentence = Sentence("Dıktor olaç yazdı")
    let corrected = spellChecker.spellCheck(sentence)
    
Output:

    Doktor ilaç yazdı

For Contibutors
============

### Package.swift file

1. Dependencies should be given w.r.t github.
```
    dependencies: [
        .package(name: "MorphologicalAnalysis", url: "https://github.com/StarlangSoftware/TurkishMorphologicalAnalysis-Swift.git", .exact("1.0.6"))],
```
2. Targets should include direct dependencies, files to be excluded, and all resources.
```
    targets: [
        .target(
	dependencies: ["MorphologicalAnalysis"],
	exclude: ["turkish1944_dictionary.txt", "turkish1944_wordnet.xml",
	"turkish1955_dictionary.txt", "turkish1955_wordnet.xml",
	"turkish1959_dictionary.txt", "turkish1959_wordnet.xml",
	"turkish1966_dictionary.txt", "turkish1966_wordnet.xml",
	"turkish1969_dictionary.txt", "turkish1969_wordnet.xml",
	"turkish1974_dictionary.txt", "turkish1974_wordnet.xml",
	"turkish1983_dictionary.txt", "turkish1983_wordnet.xml",
	"turkish1988_dictionary.txt", "turkish1988_wordnet.xml",
	"turkish1998_dictionary.txt", "turkish1998_wordnet.xml"],
	resources:
[.process("turkish_wordnet.xml"),.process("english_wordnet_version_31.xml"),.process("english_exception.xml")]),
```
3. Test targets should include test directory.
```
	.testTarget(
		name: "WordNetTests",
		dependencies: ["WordNet"]),
```

### Data files
1. Add data files to the project folder.

### Swift files

1. Do not forget to comment each function.
```
   /**
     * Returns the value to which the specified key is mapped.
     - Parameters:
        - id: String id of a key
     - Returns: value of the specified key
     */
    public func singleMap(id: String) -> String{
        return map[id]!
    }
```
2. Do not forget to define classes as open in order to be able to extend them in other packages.
```
	open class Word : Comparable, Equatable, Hashable
```
3. Function names should follow caml case.
```
	public func map(id: String)->String?
```
4. Write getter and setter methods.
```
	public func getSynSetId() -> String{
	public func setOrigin(origin: String){
```
5. Use separate test class extending XCTestCase for testing purposes.
```
final class WordNetTest: XCTestCase {
    var turkish : WordNet = WordNet()
    
    func testSize() {
        XCTAssertEqual(78326, turkish.size())
    }
```
6. Enumerated types should be declared as enum.
```
public enum CategoryType : String{
    case MATHEMATICS
    case SPORT
    case MUSIC
```
7. Implement == operator and hasher method for hashing purposes.
```
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    public static func == (lhs: Relation, rhs: Relation) -> Bool {
        return lhs.name == rhs.name
    }
```
8. Make classes Comparable for comparison, Equatable for equality, and Hashable for hashing check.
```
	open class Word : Comparable, Equatable, Hashable
```
9. Implement < operator for comparison purposes.
```
    public static func < (lhs: Word, rhs: Word) -> Bool {
        return lhs.name < rhs.name
    }
```
10. Implement description for toString method.
```
	open func description() -> String{
```
11. Use Bundle and XMLParserDelegate for parsing Xml files.
```
	let url = Bundle.module.url(forResource: fileName, withExtension: "xml")
	var parser : XMLParser = XMLParser(contentsOf: url!)!
	parser.delegate = self
	parser.parse()
```
also use parser method.
```
public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
```
