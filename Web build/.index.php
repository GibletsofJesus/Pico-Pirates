<!doctype html>
<html>
<head>
   <meta charset="UTF-8">
   <link rel="shortcut icon" href="./.favicon.ico">
   <title>Useful snippets</title>

   <link rel="stylesheet" href="./.style.css">
   <script src="./.sorttable.js"></script>
</head>

<body>
<div id="container">
	<h1>Useful snippets</h1>

	<table class="sortable">
	<thead>
        <tr>
          <th>Name</th>
          <th>Date Modified</th>
        </tr>
      </thead>
	    <tbody><?php

	// Adds pretty filesizes
	function pretty_filesize($file) {
		$size=filesize($file);
		if($size<1024){$size=$size." Bytes";}
		elseif(($size<1048576)&&($size>1023)){$size=round($size/1024, 1)." KB";}
		elseif(($size<1073741824)&&($size>1048575)){$size=round($size/1048576, 1)." MB";}
		else{$size=round($size/1073741824, 1)." GB";}
		return $size;
	}
	
	$hide=".";
	$ahref="./?hidden";
	$atext="Show";	 

	//Get file array
	$myDirectory=opendir(".");
	while($entryName=readdir($myDirectory))
	{
	   $dirArray[]=$entryName;
	}
	closedir($myDirectory);

	// Sorts files
	sort($dirArray);

	// Loops through the array of files
	for($index=0; $index < count($dirArray); $index++) {
		$fileEntry=$dirArray[$index];
	// Decides if hidden files should be displayed, based on query above.
	    if(substr("$fileEntry", strlen($fileEntry)-5,strlen($fileEntry))==".html" or substr("$fileEntry",strlen($fileEntry)-4,strlen($fileEntry))==".txt" or (!strpos($fileEntry,'.') and substr("$fileEntry",0,1)!=".")) 
		{

	// Resets Variables
		$class="file";

	// Gets File Names
		if (strpos($fileEntry,'.'))
		{			
			$name=substr("$fileEntry",0,strlen($fileEntry)-5);
		}
		else
		{
			$name=$fileEntry;
		}
		$namehref=$fileEntry;
		
		// Gets Date Modified Data
        $modtime=date("M j Y g:i A", filemtime($fileEntry));
        $timekey=date("YmdHis", filemtime($fileEntry));

	// Separates directories, and performs operations on those directories
		if(is_dir($fileEntry))
		{
			$extn="&lt;Directory&gt;";
			$size="&lt;Directory&gt;";
			$sizekey="0";
			$class="dir";
		}
		else
		{
            $class="file";
		}
		// Cleans up . and .. directories
		if($name!=".")
		{
			if($name=="..")
			{
				$name=".. (Parent Directory)";
				$extn="&lt;System Dir&gt;";
			}
			
			// Output
			echo("
				<tr class='$class'>
					<td><a href='./$namehref' class='name'>$name</a></td>
					<td sorttable_customkey='$timekey'><a href='./$namehref'>$modtime</a></td>
				</tr>"
			);
		}
	   }
	}
	?>
	    </tbody>
	</table>
</div>
<a href="..">Go back</a>
</body>
</html>