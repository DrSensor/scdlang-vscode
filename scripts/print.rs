//! Highlights the files given on the command line, in parallel.
//! FIXME: Prints the highlighted output to stdout.

use syntect::dumps::from_dump_file;
use syntect::easy::HighlightFile;
use syntect::highlighting::ThemeSet;
use syntect::parsing::SyntaxSet;

use std::{io::BufRead, path::Path, process};

fn usage_and_exit() -> ! {
	println!(
		"USAGE: print file.ext syntax.packdump\n \
		 print file.ext theme.themedump theme-name.{{light|dark}}"
	);
	process::exit(2);
}

fn main() {
	let mut env = std::env::args().skip(1);
	if let (Some(ref file), Some(ref dump)) = (env.next(), env.next()) {
		let dump_ext = Path::new(dump).extension().and_then(|s| s.to_str());
		let (syntax, theme) = match dump_ext {
			Some("packdump") => (
				from_dump_file(dump).expect("packdump exists"),
				ThemeSet::load_defaults().themes["base16-ocean.dark"].clone(),
			),
			Some("themedump") => {
				let theme: ThemeSet = from_dump_file(dump).expect("themedump exists");
				(
					SyntaxSet::load_defaults_newlines(),
					(env.next().as_ref()) // theme-name
						.map_or(theme.themes["base16-ocean.dark"].clone(), |name| theme.themes[name].clone()),
				)
			}
			_ => usage_and_exit(),
		};

		let mut highlighter = HighlightFile::new(file, &syntax, &theme).expect("file exists");
		let mut line = String::new();
		while highlighter.reader.read_line(&mut line).unwrap() > 0 {
			let regions = highlighter.highlight_lines.highlight(&line, &syntax);
			print!("{}", syntect::util::as_24_bit_terminal_escaped(&regions[..], true));
			line.clear(); // read_line appends so we need to clear between lines
		}
	} else {
		usage_and_exit();
	}
}
