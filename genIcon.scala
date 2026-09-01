#!/usr/bin/env -S scala-cli shebang

//> using scala 3.8.4
//> using jvm 21

//> using dep com.lihaoyi::scalatags:0.13.1
//> using dep org.virtuslab::scala-yaml:0.3.2
//> using dep org.commonmark:commonmark:0.29.0

import scala.util.Random

import scalatags.Text.implicits.*
import scalatags.Text.svgAttrs.*
// import scalatags.Text.svgTags.*

val WIDTH = 1024.0
val HEIGHT = 1024.0
val NUM_BOOKS = 7
val FONT_SIZE = WIDTH/NUM_BOOKS/2

val colors = Seq(
  "maroon",
  "darkred",
  "navy",
  "darkblue",
  "darkgreen",
  "brown"
)

def shuffleNoRepeat[T](xs: Seq[T]): Iterator[T] = new Iterator[T] {
  private val rng = Random()
  private var last = xs.length
  def hasNext = true
  def next(): T = {
    val i = rng.between(0, xs.length - 1)
    last = if (i >= last) i + 1 else i
    xs(last)
  }
}

@main
def genIcon() = {
  import scalatags.Text.svgTags.*
  println(svg(xmlns:="http://www.w3.org/2000/svg", width:=WIDTH, height:=HEIGHT,
    tag("style")(s"""
      @import url('https://fonts.googleapis.com/css2?family=Eczar&display=swap');

      text {
        font-family: 'Eczar';
        font-size: ${FONT_SIZE}px;
        fill: gold;
      }
    """),
    rect(width:="100%", height:="100%", fill:="white"),
    for ((color, i) <- shuffleNoRepeat(colors).take(NUM_BOOKS).toSeq.zipWithIndex) yield {
    // for (i <- 0 until NUM_BOOKS) yield {
      val _height = Random.between(HEIGHT/2, HEIGHT)
      val _x = i*WIDTH/NUM_BOOKS
      val _y = (HEIGHT - _height)
      frag(
        rect(
          x:=_x,
          y:=_y,
          width:=WIDTH/NUM_BOOKS,
          height:=_height,
          fill:=color,
          // fill:=Random.nextBytes(3).map(_ + 127).mkString("rgb(", ", ", ")")
        ),
        text(transform:=s"translate(${_x + FONT_SIZE}, ${_y + FONT_SIZE}) rotate(90)", alignmentBaseline:="middle", s"Hymnal #${i + 1}")
      )
    },
  ).render)
}
