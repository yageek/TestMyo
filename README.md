# Test Application

As specified during the interview, I contribute to the [ProcedureKit](https://github.com/ProcedureKit/ProcedureKit) 
project. This was the occastion to test the maturity of the framework.

Each behaviour of the application is "managed" by a procedure.
By taking advantages of Swift protocol, it is easy to create
small primitives operations for marshalling/unmarshalling, downloading,
checking code API, etc .. and build on top of this small sets more 
application related operations.

The basic operations for download/upload and the JSON marshalling classes
has been taken from an another project of mine and adapted to this case.

The advantages I see by using operations is the encourage of reusing 
and the facilitate the tests. 

I have a small glitch with the splash screen on my side.
I had no time to really dig this, sorry for that.

# Compilation

Install dependencies with Carthage:

```
carthage update
```

Open the project on XCode and compile.