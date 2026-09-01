#!/usr/bin/env -S scala-cli shebang

//> using scala 3.8.4
//> using jvm 21

@main
def sort() = {
  val lines = Iterator.unfold(io.StdIn) { stdin =>
    Option(stdin.readLine()).map((_, stdin))
  }.toSeq

  val re = """"num": "(\d+)(\w?)"""".r.unanchored
  val sorted = lines.sortBy {
    case re(d, l) => (d.toInt, l)
    case _ => (0, "")
  }

  // println(sorted.length)
  println(sorted.mkString("\n"))
}
